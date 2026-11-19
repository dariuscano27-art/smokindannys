-- ============================================================================
-- SMOKIN DANNYS - PHASE 2: ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all sensitive tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurant_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_addon_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_addon_group_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_item_addons ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos_transaction_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_stocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Security helper function for role checks in public schema
CREATE OR REPLACE FUNCTION public.user_has_role(required_role user_role_enum)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_id = auth.uid() AND role = required_role
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Profiles
CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- User Roles (Read by owner/self, written by owner only)
CREATE POLICY "Users view own role" ON user_roles FOR SELECT USING (auth.uid() = user_id OR public.user_has_role('owner'));
CREATE POLICY "Only owners manage roles" ON user_roles FOR ALL USING (public.user_has_role('owner'));

-- Catalog (Public read, Owner write)
CREATE POLICY "Categories viewable by everyone" ON categories FOR SELECT USING (true);
CREATE POLICY "Products viewable by everyone" ON products FOR SELECT USING (true);
CREATE POLICY "Variants viewable by everyone" ON product_variants FOR SELECT USING (true);
CREATE POLICY "Addons viewable by everyone" ON product_addon_groups FOR SELECT USING (true);
CREATE POLICY "Addon items viewable by everyone" ON product_addon_group_items FOR SELECT USING (true);

CREATE POLICY "Owners manage catalog" ON categories FOR ALL USING (public.user_has_role('owner'));
CREATE POLICY "Owners manage products" ON products FOR ALL USING (public.user_has_role('owner'));
CREATE POLICY "Owners manage variants" ON product_variants FOR ALL USING (public.user_has_role('owner'));
CREATE POLICY "Owners manage addons" ON product_addon_groups FOR ALL USING (public.user_has_role('owner'));
CREATE POLICY "Owners manage addon items" ON product_addon_group_items FOR ALL USING (public.user_has_role('owner'));

-- Shopping Cart & Addresses
CREATE POLICY "Users manage own cart" ON carts FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own cart items" ON cart_items FOR ALL USING (
    EXISTS (SELECT 1 FROM carts WHERE carts.id = cart_items.cart_id AND carts.user_id = auth.uid())
);
CREATE POLICY "Users manage own addresses" ON customer_addresses FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own favorites" ON favorites FOR ALL USING (auth.uid() = user_id);

-- Orders
CREATE POLICY "Customers view own orders, staff view all" ON orders FOR SELECT USING (
    auth.uid() = customer_id OR public.user_has_role('owner') OR public.user_has_role('cashier')
);
CREATE POLICY "Customers create own orders" ON orders FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "Staff update orders" ON orders FOR UPDATE USING (public.user_has_role('owner') OR public.user_has_role('cashier'));

CREATE POLICY "Order items viewable by authorized" ON order_items FOR SELECT USING (
    EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND (orders.customer_id = auth.uid() OR public.user_has_role('owner') OR public.user_has_role('cashier')))
);
CREATE POLICY "Order item addons viewable by authorized" ON order_item_addons FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM order_items
        JOIN orders ON orders.id = order_items.order_id
        WHERE order_items.id = order_item_addons.order_item_id
        AND (orders.customer_id = auth.uid() OR public.user_has_role('owner') OR public.user_has_role('cashier'))
    )
);

-- POS & Payments
CREATE POLICY "Cashier and owner manage POS transactions" ON pos_transactions FOR ALL USING (
    public.user_has_role('cashier') OR public.user_has_role('owner')
);
CREATE POLICY "Cashier and owner manage POS items" ON pos_transaction_items FOR ALL USING (
    public.user_has_role('cashier') OR public.user_has_role('owner')
);
CREATE POLICY "Payments viewable by customer/staff" ON payments FOR SELECT USING (
    EXISTS (SELECT 1 FROM orders WHERE orders.id = payments.order_id AND (orders.customer_id = auth.uid() OR public.user_has_role('owner') OR public.user_has_role('cashier')))
);
CREATE POLICY "Staff manage payments" ON payments FOR ALL USING (public.user_has_role('owner') OR public.user_has_role('cashier'));

-- Inventory & Expenses (Owner & Cashier)
CREATE POLICY "Staff view inventory" ON inventory_stocks FOR SELECT USING (public.user_has_role('owner') OR public.user_has_role('cashier'));
CREATE POLICY "Owners manage inventory" ON inventory_stocks FOR ALL USING (public.user_has_role('owner'));
CREATE POLICY "Owners manage expenses" ON expenses FOR ALL USING (public.user_has_role('owner'));
CREATE POLICY "Owners view audit logs" ON audit_logs FOR SELECT USING (public.user_has_role('owner'));

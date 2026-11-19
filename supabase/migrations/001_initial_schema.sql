-- ============================================================================
-- SMOKIN DANNYS FOOD ORDERING & POS SYSTEM - SUPABASE INITIAL SCHEMA
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. IDENTITY & ACCESS
-- ============================================================================

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TYPE user_role_enum AS ENUM ('customer', 'owner', 'cashier');

CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    role user_role_enum DEFAULT 'customer' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, role)
);

CREATE TABLE staff_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
    pin_code TEXT,
    hourly_rate INT DEFAULT 0,
    hired_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE staff_shifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id UUID REFERENCES staff_accounts(id) ON DELETE CASCADE NOT NULL,
    clock_in TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    clock_out TIMESTAMPTZ,
    starting_cash INT DEFAULT 0 NOT NULL,
    ending_cash INT DEFAULT 0,
    expected_cash INT DEFAULT 0,
    actual_cash INT DEFAULT 0,
    discrepancy_note TEXT,
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'closed')) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE user_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    fcm_token TEXT NOT NULL,
    device_name TEXT,
    platform TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- 2. RESTAURANT CONFIGURATION
-- ============================================================================

CREATE TABLE restaurant_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT DEFAULT 'Smokin Dannys BBQ & Grill' NOT NULL,
    tagline TEXT,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    address TEXT NOT NULL,
    logo_url TEXT,
    currency_symbol TEXT DEFAULT '₱' NOT NULL,
    tax_percentage NUMERIC(5,2) DEFAULT 12.00 NOT NULL,
    service_charge_percentage NUMERIC(5,2) DEFAULT 5.00 NOT NULL,
    is_accepting_orders BOOLEAN DEFAULT TRUE NOT NULL,
    auto_accept_orders BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE operating_hours (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    day_of_week INT CHECK (day_of_week BETWEEN 0 AND 6) NOT NULL,
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    is_closed BOOLEAN DEFAULT FALSE NOT NULL,
    UNIQUE(day_of_week)
);

CREATE TABLE delivery_zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    zone_name TEXT NOT NULL,
    base_fee INT NOT NULL,
    min_order_amount INT NOT NULL,
    estimated_delivery_minutes INT DEFAULT 45 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE payment_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_name TEXT UNIQUE NOT NULL,
    is_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    credentials JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- 3. PRODUCT CATALOG
-- ============================================================================

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    display_order INT DEFAULT 0 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    description TEXT,
    base_price INT NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE NOT NULL,
    is_featured BOOLEAN DEFAULT FALSE NOT NULL,
    preparation_time_minutes INT DEFAULT 15 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE product_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    image_url TEXT NOT NULL,
    display_order INT DEFAULT 0 NOT NULL
);

CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    price_modifier INT DEFAULT 0 NOT NULL,
    is_available BOOLEAN DEFAULT TRUE NOT NULL
);

CREATE TABLE product_addon_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    min_select INT DEFAULT 0 NOT NULL,
    max_select INT DEFAULT 1 NOT NULL,
    is_required BOOLEAN DEFAULT FALSE NOT NULL
);

CREATE TABLE product_addon_group_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID REFERENCES product_addon_groups(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    price INT DEFAULT 0 NOT NULL,
    is_available BOOLEAN DEFAULT TRUE NOT NULL
);

CREATE TABLE product_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE UNIQUE NOT NULL,
    is_in_stock BOOLEAN DEFAULT TRUE NOT NULL,
    stock_count INT DEFAULT 0 NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- 4. SHOPPING & CART
-- ============================================================================

CREATE TABLE carts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_id UUID REFERENCES carts(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    variant_id UUID REFERENCES product_variants(id) ON DELETE SET NULL,
    quantity INT CHECK (quantity > 0) NOT NULL,
    special_instructions TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE customer_addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    label TEXT DEFAULT 'Home' NOT NULL,
    recipient_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    street_address TEXT NOT NULL,
    barangay TEXT,
    city TEXT NOT NULL,
    landmark TEXT,
    latitude NUMERIC(10,8),
    longitude NUMERIC(11,8),
    is_default BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, product_id)
);

-- ============================================================================
-- 5. ORDERS
-- ============================================================================

CREATE TYPE order_status_enum AS ENUM ('pending', 'accepted', 'preparing', 'ready', 'completed', 'cancelled');
CREATE TYPE order_type_enum AS ENUM ('delivery', 'pickup', 'dine_in');

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number TEXT UNIQUE NOT NULL,
    customer_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    order_type order_type_enum DEFAULT 'delivery' NOT NULL,
    status order_status_enum DEFAULT 'pending' NOT NULL,
    subtotal INT NOT NULL,
    tax_amount INT NOT NULL,
    service_charge INT NOT NULL,
    delivery_fee INT DEFAULT 0 NOT NULL,
    discount_amount INT DEFAULT 0 NOT NULL,
    total_amount INT NOT NULL,
    delivery_address_json JSONB,
    customer_notes TEXT,
    is_paid BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    product_name_snapshot TEXT NOT NULL,
    unit_price_snapshot INT NOT NULL,
    quantity INT NOT NULL,
    variant_name_snapshot TEXT,
    variant_price_snapshot INT DEFAULT 0 NOT NULL,
    total_price INT NOT NULL,
    special_instructions TEXT
);

CREATE TABLE order_item_addons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_item_id UUID REFERENCES order_items(id) ON DELETE CASCADE NOT NULL,
    addon_name_snapshot TEXT NOT NULL,
    addon_price_snapshot INT NOT NULL
);

CREATE TABLE order_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
    status order_status_enum NOT NULL,
    changed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE order_cancellations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE UNIQUE NOT NULL,
    reason TEXT NOT NULL,
    cancelled_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE order_refunds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
    refund_amount INT NOT NULL,
    reason TEXT NOT NULL,
    approved_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- 6. PAYMENTS & POS
-- ============================================================================

CREATE TYPE payment_status_enum AS ENUM ('pending', 'verified', 'rejected', 'completed');

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
    payment_method TEXT NOT NULL,
    amount INT NOT NULL,
    status payment_status_enum DEFAULT 'pending' NOT NULL,
    reference_number TEXT,
    cash_received INT,
    change_amount INT,
    processed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE payment_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID REFERENCES payments(id) ON DELETE CASCADE UNIQUE NOT NULL,
    proof_image_url TEXT,
    verified_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE pos_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_number TEXT UNIQUE NOT NULL,
    cashier_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    shift_id UUID REFERENCES staff_shifts(id) ON DELETE SET NULL,
    subtotal INT NOT NULL,
    tax_amount INT NOT NULL,
    service_charge INT NOT NULL,
    discount_amount INT DEFAULT 0 NOT NULL,
    total_amount INT NOT NULL,
    cash_received INT NOT NULL,
    change_amount INT NOT NULL,
    payment_method TEXT DEFAULT 'cash' NOT NULL,
    status TEXT DEFAULT 'completed' CHECK (status IN ('completed', 'held', 'cancelled')) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE pos_transaction_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID REFERENCES pos_transactions(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    unit_price INT NOT NULL,
    quantity INT NOT NULL,
    total_price INT NOT NULL
);

CREATE TABLE pos_holds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cashier_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    hold_name TEXT NOT NULL,
    cart_snapshot JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE cash_drawer_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shift_id UUID REFERENCES staff_shifts(id) ON DELETE CASCADE NOT NULL,
    action_type TEXT CHECK (action_type IN ('cash_in', 'cash_out', 'drop')) NOT NULL,
    amount INT NOT NULL,
    reason TEXT NOT NULL,
    performed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    pos_transaction_id UUID REFERENCES pos_transactions(id) ON DELETE CASCADE,
    receipt_data JSONB NOT NULL,
    printed_count INT DEFAULT 1 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- 7. INVENTORY
-- ============================================================================

CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    contact_person TEXT,
    phone TEXT,
    email TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE ingredients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    unit TEXT NOT NULL,
    unit_cost INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE inventory_stocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ingredient_id UUID REFERENCES ingredients(id) ON DELETE CASCADE UNIQUE NOT NULL,
    quantity NUMERIC(10,2) DEFAULT 0.00 NOT NULL,
    low_stock_threshold NUMERIC(10,2) DEFAULT 10.00 NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE inventory_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ingredient_id UUID REFERENCES ingredients(id) ON DELETE CASCADE NOT NULL,
    change_amount NUMERIC(10,2) NOT NULL,
    movement_type TEXT CHECK (movement_type IN ('stock_in', 'stock_out', 'adjustment', 'order_deduction')) NOT NULL,
    reason TEXT,
    performed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE product_recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    ingredient_id UUID REFERENCES ingredients(id) ON DELETE CASCADE NOT NULL,
    quantity_required NUMERIC(10,2) NOT NULL,
    UNIQUE(product_id, ingredient_id)
);

CREATE TABLE stock_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ingredient_id UUID REFERENCES ingredients(id) ON DELETE CASCADE NOT NULL,
    current_quantity NUMERIC(10,2) NOT NULL,
    threshold NUMERIC(10,2) NOT NULL,
    is_resolved BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- 8. PROMOTIONS & DISCOUNTS
-- ============================================================================

CREATE TABLE vouchers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL,
    discount_type TEXT CHECK (discount_type IN ('percentage', 'fixed')) NOT NULL,
    discount_value INT NOT NULL,
    min_order_amount INT DEFAULT 0 NOT NULL,
    max_discount_amount INT,
    usage_limit INT,
    times_used INT DEFAULT 0 NOT NULL,
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE voucher_redemptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    voucher_id UUID REFERENCES vouchers(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE discounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    percentage NUMERIC(5,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- 9. CUSTOMER ENGAGEMENT
-- ============================================================================

CREATE TABLE product_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5) NOT NULL,
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(product_id, user_id)
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE NOT NULL,
    payload JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- 10. REPORTING & SECURITY
-- ============================================================================

CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    amount INT NOT NULL,
    recorded_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    expense_date DATE DEFAULT CURRENT_DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    details JSONB,
    ip_address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key TEXT UNIQUE NOT NULL,
    value JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================================

-- Order number generator function
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
DECLARE
    today_prefix TEXT;
    seq_val INT;
    new_order_num TEXT;
BEGIN
    today_prefix := 'SD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-';

    SELECT COUNT(*) + 1 INTO seq_val
    FROM orders
    WHERE order_number LIKE today_prefix || '%';

    new_order_num := today_prefix || LPAD(seq_val::TEXT, 4, '0');
    NEW.order_number := new_order_num;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_order_number
BEFORE INSERT ON orders
FOR EACH ROW
WHEN (NEW.order_number IS NULL OR NEW.order_number = '')
EXECUTE FUNCTION generate_order_number();

-- POS Transaction number generator
CREATE OR REPLACE FUNCTION generate_pos_transaction_number()
RETURNS TRIGGER AS $$
DECLARE
    today_prefix TEXT;
    seq_val INT;
    new_trans_num TEXT;
BEGIN
    today_prefix := 'POS-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-';

    SELECT COUNT(*) + 1 INTO seq_val
    FROM pos_transactions
    WHERE transaction_number LIKE today_prefix || '%';

    new_trans_num := today_prefix || LPAD(seq_val::TEXT, 4, '0');
    NEW.transaction_number := new_trans_num;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_pos_transaction_number
BEFORE INSERT ON pos_transactions
FOR EACH ROW
WHEN (NEW.transaction_number IS NULL OR NEW.transaction_number = '')
EXECUTE FUNCTION generate_pos_transaction_number();

-- Update updated_at timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_modtime BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_modtime BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_modtime BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_restaurant_settings_modtime BEFORE UPDATE ON restaurant_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

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

-- ============================================================================
-- INITIAL SEED DATA
-- ============================================================================

INSERT INTO restaurant_settings (name, tagline, phone, email, address, currency_symbol, tax_percentage, service_charge_percentage)
VALUES ('Smokin Dannys BBQ & Grill', 'Authentic Texas Style BBQ & Grill', '+63 917 123 4567', 'orders@smokindannys.com', '123 Grill Street, Metro Manila, Philippines', '₱', 12.00, 5.00)
ON CONFLICT DO NOTHING;

INSERT INTO categories (name, description, display_order) VALUES
('BBQ Ribs & Steaks', 'Slow-smoked tender ribs and juicy steaks', 1),
('Burgers & Sandwiches', 'Gourmet burgers with smoky flavor', 2),
('Sides & Appetizers', 'Crispy fries, onion rings, and wings', 3),
('Drinks & Desserts', 'Refreshing beverages and sweet treats', 4)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SMOKIN DANNYS - PHASE 3: FUNCTIONS, TRIGGERS & RPCs
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

DROP TRIGGER IF EXISTS set_order_number ON orders;
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

DROP TRIGGER IF EXISTS set_pos_transaction_number ON pos_transactions;
CREATE TRIGGER set_pos_transaction_number
BEFORE INSERT ON pos_transactions
FOR EACH ROW
WHEN (NEW.transaction_number IS NULL OR NEW.transaction_number = '')
EXECUTE FUNCTION generate_pos_transaction_number();

-- Updated_at timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_profiles_modtime ON profiles;
CREATE TRIGGER update_profiles_modtime BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_products_modtime ON products;
CREATE TRIGGER update_products_modtime BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_orders_modtime ON orders;
CREATE TRIGGER update_orders_modtime BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Secure RPC: Finalize POS Transaction and Deduct Inventory
CREATE OR REPLACE FUNCTION finalize_pos_sale(
    p_cashier_id UUID,
    p_shift_id UUID,
    p_subtotal INT,
    p_tax_amount INT,
    p_service_charge INT,
    p_discount_amount INT,
    p_total_amount INT,
    p_cash_received INT,
    p_change_amount INT,
    p_payment_method TEXT,
    p_items JSONB
)
RETURNS UUID
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_trans_id UUID;
    item JSONB;
BEGIN
    -- Insert POS transaction
    INSERT INTO pos_transactions (
        cashier_id, shift_id, subtotal, tax_amount, service_charge,
        discount_amount, total_amount, cash_received, change_amount, payment_method, status
    ) VALUES (
        p_cashier_id, p_shift_id, p_subtotal, p_tax_amount, p_service_charge,
        p_discount_amount, p_total_amount, p_cash_received, p_change_amount, p_payment_method, 'completed'
    ) RETURNING id INTO v_trans_id;

    -- Insert items and deduct recipe ingredients
    FOR item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        INSERT INTO pos_transaction_items (
            transaction_id, product_id, product_name, unit_price, quantity, total_price
        ) VALUES (
            v_trans_id,
            (item->>'product_id')::UUID,
            item->>'product_name',
            (item->>'unit_price')::INT,
            (item->>'quantity')::INT,
            (item->>'total_price')::INT
        );
    END LOOP;

    RETURN v_trans_id;
END;
$$ LANGUAGE plpgsql;

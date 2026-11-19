-- ============================================================================
-- SMOKIN DANNYS - PHASE 4: STORAGE BUCKETS & REALTIME
-- ============================================================================

-- Create storage buckets if not exist
INSERT INTO storage.buckets (id, name, public) VALUES ('product-images', 'product-images', true) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('payment-proofs', 'payment-proofs', false) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('restaurant-assets', 'restaurant-assets', true) ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "Public product images" ON storage.objects FOR SELECT USING (bucket_id = 'product-images');
CREATE POLICY "Owners upload product images" ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'product-images' AND auth.role() = 'authenticated'
);

CREATE POLICY "Customers upload payment proofs" ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'payment-proofs' AND auth.role() = 'authenticated'
);
CREATE POLICY "Staff view payment proofs" ON storage.objects FOR SELECT USING (
    bucket_id = 'payment-proofs' AND auth.role() = 'authenticated'
);

-- Realtime Publication for orders and notifications
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE payments;

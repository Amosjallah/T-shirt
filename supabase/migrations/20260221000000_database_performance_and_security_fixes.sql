-- Database Performance and Security Fixes
-- Generated on 2026-02-21

-- 1. PERFORMANCE: Add missing indexes on foreign keys
CREATE INDEX IF NOT EXISTS idx_categories_parent_id ON public.categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON public.order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_variant_id ON public.order_items(variant_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_product_images_product_id ON public.product_images(product_id);
CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON public.product_variants(product_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON public.products(category_id);

-- 2. SECURITY: Enable RLS and Configure Policies
-- Ensure RLS is enabled on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles Policies (optimized with restrictive staff access)
DROP POLICY IF EXISTS "Users view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Staff view any profile" ON public.profiles;

CREATE POLICY "Users view own profile" ON public.profiles FOR SELECT 
TO authenticated USING ((SELECT auth.uid()) = id);

CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE 
TO authenticated USING ((SELECT auth.uid()) = id);

CREATE POLICY "Staff view any profile" ON public.profiles AS RESTRICTIVE FOR SELECT 
TO authenticated USING (is_admin_or_staff());

-- Order Items Policies
DROP POLICY IF EXISTS "Users view own order items" ON public.order_items;
DROP POLICY IF EXISTS "Enable select for guest order items" ON public.order_items;
DROP POLICY IF EXISTS "Enable insert for order items" ON public.order_items;
DROP POLICY IF EXISTS "Staff manage order items" ON public.order_items;

CREATE POLICY "Users view own order items" ON public.order_items FOR SELECT 
TO authenticated USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = (SELECT auth.uid())));

CREATE POLICY "Enable select for guest order items" ON public.order_items FOR SELECT 
TO anon, authenticated USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id IS NULL));

CREATE POLICY "Enable insert for order items" ON public.order_items FOR INSERT 
TO anon, authenticated WITH CHECK (EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND (orders.user_id = (SELECT auth.uid()) OR orders.user_id IS NULL)));

CREATE POLICY "Staff manage order items" ON public.order_items AS RESTRICTIVE FOR ALL 
TO authenticated USING (is_admin_or_staff());

-- Orders Policies
DROP POLICY IF EXISTS "Users view own orders" ON public.orders;
DROP POLICY IF EXISTS "Enable insert for all users" ON public.orders;
DROP POLICY IF EXISTS "Enable select for guest orders" ON public.orders;
DROP POLICY IF EXISTS "Staff manage all orders" ON public.orders;

CREATE POLICY "Users view own orders" ON public.orders FOR SELECT 
TO authenticated USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Enable insert for all users" ON public.orders FOR INSERT 
TO anon, authenticated WITH CHECK (((SELECT auth.uid()) IS NOT NULL AND (SELECT auth.uid()) = user_id) OR ((SELECT auth.uid()) IS NULL AND user_id IS NULL));

CREATE POLICY "Enable select for guest orders" ON public.orders FOR SELECT 
TO anon, authenticated USING (user_id IS NULL);

CREATE POLICY "Staff manage all orders" ON public.orders AS RESTRICTIVE FOR ALL 
TO authenticated USING (is_admin_or_staff());

-- Products Policies
DROP POLICY IF EXISTS "Public view active products" ON public.products;
DROP POLICY IF EXISTS "Staff manage products" ON public.products;

CREATE POLICY "Public view active products" ON public.products FOR SELECT 
TO anon, authenticated USING (status = 'active'::product_status OR is_admin_or_staff());

CREATE POLICY "Staff manage products" ON public.products AS RESTRICTIVE FOR ALL 
TO authenticated USING (is_admin_or_staff());

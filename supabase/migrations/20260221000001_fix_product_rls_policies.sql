-- Fix Product Metadata RLS Policies
-- Adding write access for staff to categories, product_images, and product_variants

-- 1. Categories
-- Standardize public view
DROP POLICY IF EXISTS "Public view categories" ON public.categories;
CREATE POLICY "Public view categories" ON public.categories 
FOR SELECT TO anon, authenticated USING (true);

-- Add staff management
DROP POLICY IF EXISTS "Staff manage categories" ON public.categories;
CREATE POLICY "Staff manage categories" ON public.categories 
AS RESTRICTIVE FOR ALL TO authenticated USING (is_admin_or_staff());

-- 2. Product Images
-- Standardize public view
DROP POLICY IF EXISTS "Public view images" ON public.product_images;
CREATE POLICY "Public view images" ON public.product_images 
FOR SELECT TO anon, authenticated USING (true);

-- Add staff management
DROP POLICY IF EXISTS "Staff manage images" ON public.product_images;
CREATE POLICY "Staff manage images" ON public.product_images 
AS RESTRICTIVE FOR ALL TO authenticated USING (is_admin_or_staff());

-- 3. Product Variants
-- Standardize public view
DROP POLICY IF EXISTS "Public view variants" ON public.product_variants;
CREATE POLICY "Public view variants" ON public.product_variants 
FOR SELECT TO anon, authenticated USING (true);

-- Add staff management
DROP POLICY IF EXISTS "Staff manage variants" ON public.product_variants;
CREATE POLICY "Staff manage variants" ON public.product_variants 
AS RESTRICTIVE FOR ALL TO authenticated USING (is_admin_or_staff());

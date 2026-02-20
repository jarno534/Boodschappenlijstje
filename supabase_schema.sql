-- Enable UUID extension if not enabled
create extension if not exists "uuid-ossp";

-- 1. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  color TEXT NOT NULL
);

-- Turn off RLS or allow all for simple family app
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all actions for profiles" ON public.profiles FOR ALL USING (true) WITH CHECK (true);

-- Insert 4 default profiles if empty
INSERT INTO public.profiles (name, color)
SELECT * FROM (
  VALUES
    ('Papa', '#3b82f6'), -- blue
    ('Mama', '#ec4899'), -- pink
    ('Kind 1', '#22c55e'), -- green
    ('Kind 2', '#eab308')  -- yellow
) AS t(name, color)
WHERE NOT EXISTS (SELECT 1 FROM public.profiles);

-- 2. Groceries Table
CREATE TABLE IF NOT EXISTS public.groceries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  added_by UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  is_done BOOLEAN DEFAULT false,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.groceries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all actions for groceries" ON public.groceries FOR ALL USING (true) WITH CHECK (true);

-- 3. Storage Bucket
-- Please ensure you create a bucket named 'product-photos' in the Supabase Dashboard -> Storage
-- Make sure the bucket is PUBLIC so the photos can be displayed without signed URLs.
-- In SQL:
INSERT INTO storage.buckets (id, name, public) VALUES ('product-photos', 'product-photos', true) ON CONFLICT (id) DO NOTHING;

-- RLS for storage bucket
CREATE POLICY "Allow all actions for product-photos bucket" ON storage.objects FOR ALL USING (bucket_id = 'product-photos') WITH CHECK (bucket_id = 'product-photos');

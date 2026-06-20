-- Voeg de 'store' kolom toe aan de 'groceries' tabel
ALTER TABLE public.groceries ADD COLUMN IF NOT EXISTS store TEXT;

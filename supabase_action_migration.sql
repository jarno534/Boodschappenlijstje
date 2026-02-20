-- Voeg de is_action kolom toe aan de bestaande tabel
ALTER TABLE public.groceries ADD COLUMN IF NOT EXISTS is_action BOOLEAN DEFAULT false;

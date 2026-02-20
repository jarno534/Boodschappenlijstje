import { createClient } from '@supabase/supabase-js';
import { env } from '$env/dynamic/public';

const supabaseUrl = env.PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = env.PUBLIC_SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Types based on the schema
export type Profile = {
    id: string;
    name: string;
    color: string;
};

export type Grocery = {
    id: string;
    name: string;
    added_by: string;
    is_done: boolean;
    photo_url: string | null;
    created_at: string;
};

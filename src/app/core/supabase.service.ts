import { Injectable, inject } from '@angular/core';
import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { ConfigService } from './config.service';

@Injectable({ providedIn: 'root' })
export class SupabaseService {
  private readonly config = inject(ConfigService);
  readonly client: SupabaseClient = createClient(
    this.config.get().supabaseUrl,
    this.config.get().supabaseAnonKey,
  );
}

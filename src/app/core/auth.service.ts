import { Injectable, inject, signal } from '@angular/core';
import type { Session } from '@supabase/supabase-js';
import { SupabaseService } from './supabase.service';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly supabase = inject(SupabaseService);
  readonly session = signal<Session | null>(null);
  private readonly ready = this.supabase.client.auth
    .getSession()
    .then(({ data }) => this.session.set(data.session));

  constructor() {
    this.supabase.client.auth.onAuthStateChange((_event, session) => {
      this.session.set(session);
    });
  }

  waitUntilReady(): Promise<unknown> {
    return this.ready;
  }

  async signUp(email: string, password: string, nomComplet: string) {
    const { error } = await this.supabase.client.auth.signUp({
      email,
      password,
      options: { data: { nom_complet: nomComplet } },
    });
    if (error) throw error;
  }

  async signIn(email: string, password: string) {
    const { error } = await this.supabase.client.auth.signInWithPassword({ email, password });
    if (error) throw error;
  }

  async signOut() {
    await this.supabase.client.auth.signOut();
  }
}

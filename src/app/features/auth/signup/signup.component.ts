import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../../core/auth.service';

@Component({
  selector: 'app-signup',
  imports: [FormsModule, RouterLink],
  templateUrl: './signup.component.html',
})
export class SignupComponent {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  nomComplet = '';
  email = '';
  password = '';
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly done = signal(false);

  async onSubmit(): Promise<void> {
    this.error.set(null);
    this.loading.set(true);
    try {
      await this.auth.signUp(this.email, this.password, this.nomComplet);
      this.done.set(true);
    } catch (err) {
      this.error.set(err instanceof Error ? err.message : 'Inscription impossible.');
    } finally {
      this.loading.set(false);
    }
  }
}

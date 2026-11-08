import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../../core/auth.service';

@Component({
  selector: 'app-login',
  imports: [FormsModule, RouterLink],
  templateUrl: './login.component.html',
})
export class LoginComponent {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  email = '';
  password = '';
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);

  async onSubmit(): Promise<void> {
    this.error.set(null);
    this.loading.set(true);
    try {
      await this.auth.signIn(this.email, this.password);
      await this.router.navigateByUrl('/');
    } catch (err) {
      this.error.set(err instanceof Error ? err.message : 'Connexion impossible.');
    } finally {
      this.loading.set(false);
    }
  }
}

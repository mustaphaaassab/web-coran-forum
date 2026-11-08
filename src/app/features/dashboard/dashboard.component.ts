import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../core/auth.service';

@Component({
  selector: 'app-dashboard',
  template: `
    <main>
      <h1>Suivi d'apprentissage du Coran</h1>
      <p>Connecté en tant que {{ auth.session()?.user?.email }}</p>
      <button (click)="logout()">Se déconnecter</button>
    </main>
  `,
})
export class DashboardComponent {
  readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  async logout(): Promise<void> {
    await this.auth.signOut();
    await this.router.navigateByUrl('/login');
  }
}

import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import type { RuntimeConfig } from './runtime-config';

@Injectable({ providedIn: 'root' })
export class ConfigService {
  private readonly http = inject(HttpClient);
  private config?: RuntimeConfig;

  async load(): Promise<void> {
    this.config = await firstValueFrom(this.http.get<RuntimeConfig>('/config.json'));
  }

  get(): RuntimeConfig {
    if (!this.config) {
      throw new Error('ConfigService.load() must complete before get() is called.');
    }
    return this.config;
  }
}

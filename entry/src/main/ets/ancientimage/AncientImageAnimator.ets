@Component
export struct ParticleState {
  @State x: number = 0;
  @State y: number = 0;
  @State particleOpacity: number = 1;
  @State particleScale: number = 1;
  @State rotation: number = 0;

  build() {
    // Empty build method - this component is used as a data structure
  }
}

export class InkParticle {
  x: number = 0;
  y: number = 0;
  vx: number = 0;
  vy: number = 0;
  size: number = 4;
  opacity: number = 1;
  life: number = 1;
  maxLife: number = 3;
  rotation: number = 0;
  rotationSpeed: number = 0;
  color: string = '#1a1a2e';
  type: 'ink' | 'dust' | 'petal' = 'ink';

  constructor(canvasWidth: number, canvasHeight: number, type: 'ink' | 'dust' | 'petal' = 'ink') {
    this.type = type;
    this.reset(canvasWidth, canvasHeight, true);
  }

  reset(canvasWidth: number, canvasHeight: number, initial: boolean = false): void {
    switch (this.type) {
      case 'ink':
        this.x = Math.random() * canvasWidth;
        this.y = initial ? Math.random() * canvasHeight : -10;
        this.vx = (Math.random() - 0.5) * 0.8;
        this.vy = Math.random() * 0.5 + 0.2;
        this.size = Math.random() * 6 + 2;
        this.color = Math.random() > 0.5 ? '#1a1a2e' : '#2d2d44';
        this.rotationSpeed = (Math.random() - 0.5) * 2;
        break;
      case 'dust':
        this.x = Math.random() * canvasWidth;
        this.y = Math.random() * canvasHeight;
        this.vx = (Math.random() - 0.5) * 0.3;
        this.vy = -Math.random() * 0.3 - 0.1;
        this.size = Math.random() * 3 + 1;
        this.color = '#d4a574';
        this.rotationSpeed = (Math.random() - 0.5) * 1;
        break;
      case 'petal':
        this.x = initial ? Math.random() * canvasWidth : Math.random() * canvasWidth;
        this.y = initial ? Math.random() * canvasHeight : -20;
        this.vx = Math.random() * 0.5 + 0.2;
        this.vy = Math.random() * 0.8 + 0.3;
        this.size = Math.random() * 8 + 4;
        this.color = Math.random() > 0.5 ? '#e8b4b8' : '#d4a5a5';
        this.rotationSpeed = (Math.random() - 0.5) * 3;
        break;
    }
    this.opacity = Math.random() * 0.6 + 0.2;
    this.rotation = Math.random() * 360;
    this.maxLife = Math.random() * 4 + 2;
    this.life = this.maxLife;
  }

  update(dt: number, canvasWidth: number, canvasHeight: number): void {
    this.x += this.vx;
    this.y += this.vy;
    this.rotation += this.rotationSpeed;
    this.life -= dt;

    if (this.type === 'petal') {
      this.vx += Math.sin(Date.now() * 0.001 + this.x * 0.01) * 0.02;
    }

    if (this.type === 'dust') {
      this.vx += Math.sin(Date.now() * 0.0005 + this.y * 0.01) * 0.01;
    }

    this.opacity = Math.max(0, (this.life / this.maxLife) * 0.6);

    if (this.life <= 0 || this.y > canvasHeight + 20 || this.x < -20 || this.x > canvasWidth + 20) {
      this.reset(canvasWidth, canvasHeight);
    }
  }
}

export enum KenBurnsMode {
  ZOOM_IN = 'zoomIn',
  ZOOM_OUT = 'zoomOut',
  PAN_LEFT = 'panLeft',
  PAN_RIGHT = 'panRight',
  PAN_UP = 'panUp',
  PAN_DOWN = 'panDown',
  ZOOM_PAN_LEFT = 'zoomPanLeft',
  ZOOM_PAN_RIGHT = 'zoomPanRight'
}

export class KenBurnsKeyframe {
  scaleX: number = 1;
  scaleY: number = 1;
  translateX: number = 0;
  translateY: number = 0;
  duration: number = 8000;

  constructor(scaleX: number, scaleY: number, translateX: number, translateY: number, duration: number) {
    this.scaleX = scaleX;
    this.scaleY = scaleY;
    this.translateX = translateX;
    this.translateY = translateY;
    this.duration = duration;
  }
}

export class KenBurnsSequence {
  keyframes: KenBurnsKeyframe[] = [];

  static createDefault(): KenBurnsSequence {
    const seq = new KenBurnsSequence();
    seq.keyframes = [
      new KenBurnsKeyframe(1.0, 1.0, 0, 0, 0),
      new KenBurnsKeyframe(1.3, 1.3, -30, -20, 6000),
      new KenBurnsKeyframe(1.5, 1.5, 20, -40, 8000),
      new KenBurnsKeyframe(1.2, 1.2, -10, 30, 7000),
      new KenBurnsKeyframe(1.4, 1.4, 30, 10, 6000),
      new KenBurnsKeyframe(1.0, 1.0, 0, 0, 5000),
    ];
    return seq;
  }

  static createForScroll(): KenBurnsSequence {
    const seq = new KenBurnsSequence();
    seq.keyframes = [
      new KenBurnsKeyframe(1.0, 1.0, 0, 0, 0),
      new KenBurnsKeyframe(1.1, 1.1, 0, -80, 8000),
      new KenBurnsKeyframe(1.15, 1.15, 10, -160, 8000),
      new KenBurnsKeyframe(1.1, 1.1, -10, -240, 8000),
      new KenBurnsKeyframe(1.0, 1.0, 0, -300, 6000),
    ];
    return seq;
  }

  static createForZoom(): KenBurnsSequence {
    const seq = new KenBurnsSequence();
    seq.keyframes = [
      new KenBurnsKeyframe(1.0, 1.0, 0, 0, 0),
      new KenBurnsKeyframe(1.5, 1.5, -20, -15, 5000),
      new KenBurnsKeyframe(2.0, 2.0, -40, -30, 6000),
      new KenBurnsKeyframe(1.8, 1.8, 20, 10, 5000),
      new KenBurnsKeyframe(1.0, 1.0, 0, 0, 6000),
    ];
    return seq;
  }

  getTotalDuration(): number {
    let total = 0;
    for (const kf of this.keyframes) {
      total += kf.duration;
    }
    return total;
  }
}

export enum ScrollUnrollPhase {
  IDLE = 'idle',
  UNROLLING = 'unrolling',
  REVEALING = 'revealing',
  COMPLETE = 'complete'
}

export class ScrollUnrollState {
  phase: ScrollUnrollPhase = ScrollUnrollPhase.IDLE;
  progress: number = 0;
  unrollWidth: number = 0;
  revealProgress: number = 0;
  rodOffsetY: number = 0;
  shadowOpacity: number = 0.3;

  update(dt: number): void {
    switch (this.phase) {
      case ScrollUnrollPhase.UNROLLING:
        this.progress = Math.min(1, this.progress + dt * 0.15);
        this.unrollWidth = this.progress;
        this.shadowOpacity = 0.3 * (1 - this.progress * 0.5);
        if (this.progress >= 1) {
          this.phase = ScrollUnrollPhase.REVEALING;
        }
        break;
      case ScrollUnrollPhase.REVEALING:
        this.revealProgress = Math.min(1, this.revealProgress + dt * 0.2);
        this.rodOffsetY = -this.revealProgress * 30;
        if (this.revealProgress >= 1) {
          this.phase = ScrollUnrollPhase.COMPLETE;
        }
        break;
      default:
        break;
    }
  }

  start(): void {
    this.phase = ScrollUnrollPhase.UNROLLING;
    this.progress = 0;
    this.revealProgress = 0;
    this.rodOffsetY = 0;
  }

  isComplete(): boolean {
    return this.phase === ScrollUnrollPhase.COMPLETE;
  }
}

export enum MusicBeat {
  SLOW = 'slow',
  MEDIUM = 'medium',
  FAST = 'fast'
}

export class MusicSyncController {
  bpm: number = 60;
  currentBeat: MusicBeat = MusicBeat.SLOW;
  beatProgress: number = 0;
  lastBeatTime: number = 0;
  onBeat: (() => void) | null = null;

  constructor(bpm: number = 60) {
    this.bpm = bpm;
  }

  update(currentTime: number): void {
    const beatInterval = 60000 / this.bpm;
    const elapsed = currentTime - this.lastBeatTime;

    this.beatProgress = elapsed / beatInterval;

    if (elapsed >= beatInterval) {
      this.lastBeatTime = currentTime;
      this.beatProgress = 0;
      if (this.onBeat) {
        this.onBeat();
      }
    }
  }

  getIntensity(): number {
    return Math.sin(this.beatProgress * Math.PI);
  }

  setBPM(bpm: number): void {
    this.bpm = bpm;
    if (bpm <= 60) {
      this.currentBeat = MusicBeat.SLOW;
    } else if (bpm <= 100) {
      this.currentBeat = MusicBeat.MEDIUM;
    } else {
      this.currentBeat = MusicBeat.FAST;
    }
  }
}

export class AncientFilterConfig {
  sepiaIntensity: number = 0.12;
  vignetteIntensity: number = 0.25;
  grainIntensity: number = 0.05;
  warmth: number = 0.06;
  contrast: number = 1.05;

  static createClassic(): AncientFilterConfig {
    const config = new AncientFilterConfig();
    config.sepiaIntensity = 0.12;
    config.vignetteIntensity = 0.25;
    config.grainIntensity = 0.05;
    config.warmth = 0.06;
    config.contrast = 1.05;
    return config;
  }

  static createDramatic(): AncientFilterConfig {
    const config = new AncientFilterConfig();
    config.sepiaIntensity = 0.3;
    config.vignetteIntensity = 0.4;
    config.grainIntensity = 0.08;
    config.warmth = 0.1;
    config.contrast = 1.15;
    return config;
  }

  static createSoft(): AncientFilterConfig {
    const config = new AncientFilterConfig();
    config.sepiaIntensity = 0.08;
    config.vignetteIntensity = 0.15;
    config.grainIntensity = 0.03;
    config.warmth = 0.03;
    config.contrast = 1.02;
    return config;
  }
}

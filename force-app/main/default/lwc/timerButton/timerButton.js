import { api, LightningElement } from 'lwc';

const DELAY_SECONDS = 30;

export default class TimerButton extends LightningElement {
    // Provided by the Agentforce CLT editor framework.
    @api readOnly = false;

    _value = {};
    countdown = DELAY_SECONDS;
    interval;

    @api
    get value() {
        return this._value;
    }
    set value(val) {
        this._value = val ?? {};
    }

    get isWaiting() {
        return this.countdown > 0;
    }

    get statusLabel() {
        return this.isWaiting
            ? `Délai de sécurité en cours : ${this.countdown}s`
            : 'Délai écoulé — cliquez sur Valider ci-dessous';
    }

    get progressStyle() {
        const pct = Math.round(
            ((DELAY_SECONDS - this.countdown) / DELAY_SECONDS) * 100
        );
        return `width: ${pct}%`;
    }

    connectedCallback() {
        this.startTimer();
    }

    disconnectedCallback() {
        clearInterval(this.interval);
    }

    startTimer() {
        this.interval = setInterval(() => {
            this.countdown -= 1;
            if (this.countdown <= 0) {
                this.countdown = 0;
                clearInterval(this.interval);
                this.confirm();
            }
        }, 1000);
    }

    // Once the delay elapses, mark the value valid so the platform Submit
    // button becomes actionable (required token is no longer blank).
    confirm() {
        this._value = { confirmationToken: 'CONFIRMED' };
        this.dispatchEvent(
            new CustomEvent('valuechange', {
                detail: { value: this._value }
            })
        );
    }
}

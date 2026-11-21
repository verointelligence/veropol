export default function Backdrop() {
    return (
        <div className="backdrop" aria-hidden="true">
            <svg className="bd-shapes" viewBox="0 0 1440 900" preserveAspectRatio="xMidYMid slice" focusable="false">
                <polygon className="bd-a" points="1440,0 1440,560 960,0" />
                <polygon className="bd-b" points="0,900 0,380 560,900" />
                <polygon className="bd-c" points="1440,900 1440,700 1180,900" />
                <path className="bd-line" d="M1020 0 L1440 590" />
                <path className="bd-line" d="M0 330 L580 900" />
                <path className="bd-v" d="M1120 150 L1215 345 L1310 150" />
            </svg>
            <div className="bd-grid" />
            <div className="bd-glow" />
        </div>
    );
}

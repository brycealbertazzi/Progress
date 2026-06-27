import Image from "next/image";
import Link from "next/link";
import ScreenshotCarousel from "@/components/ScreenshotCarousel";

const APP_STORE_URL = "YOUR_APP_STORE_URL_HERE";

const features = [
  {
    emoji: "🏋️",
    title: "Log Every Set",
    description:
      "Track weight, reps, and time for any exercise. Full support for bodyweight movements and timed holds.",
  },
  {
    emoji: "📈",
    title: "Visualize Progress",
    description:
      "Interactive volume charts with weight-change indicators. See the exact sessions where you pushed harder.",
  },
  {
    emoji: "📁",
    title: "Stay Organized",
    description:
      "Group exercises into folders, drag to reorder, and build a structure that mirrors the way you train.",
  },
  {
    emoji: "📅",
    title: "Training History",
    description:
      "Tap any day on the calendar to review every set you logged. Your complete workout history, always a tap away.",
  },
];

export default function Home() {
  return (
    <main className="bg-[#0E0E0E] text-white overflow-x-hidden">

      {/* ── Navbar ──────────────────────────────────────────────── */}
      <nav className="fixed top-0 inset-x-0 z-50 flex items-center justify-between px-5 sm:px-8 lg:px-10 py-3.5 sm:py-4 bg-[#0E0E0E]/80 backdrop-blur-md border-b border-white/5">
        <span className="text-base sm:text-lg font-bold tracking-tight">Progress</span>
        <a
          href={APP_STORE_URL}
          className="bg-[#6C63FF] hover:bg-[#5A52D5] active:scale-95 text-white text-xs sm:text-sm font-semibold px-4 sm:px-5 py-2 rounded-full transition-all"
        >
          Download
        </a>
      </nav>

      {/* ── Hero ────────────────────────────────────────────────── */}
      <section className="relative flex items-center min-h-screen pt-16 sm:pt-20">
        {/* Background glow */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute top-[-15%] left-1/2 -translate-x-1/2 w-[600px] sm:w-[900px] h-[500px] sm:h-[700px] bg-[#6C63FF]/8 rounded-full blur-[120px] sm:blur-[150px]" />
        </div>

        <div className="relative z-10 max-w-7xl mx-auto w-full px-5 sm:px-8 lg:px-10 grid grid-cols-1 lg:grid-cols-2 gap-10 lg:gap-20 items-center py-20 sm:py-28 lg:py-36">
          {/* Text */}
          <div className="text-center lg:text-left">
            <span className="inline-block bg-[#6C63FF]/15 border border-[#6C63FF]/30 text-[#6C63FF] text-[11px] sm:text-xs font-semibold uppercase tracking-widest px-3 sm:px-4 py-1.5 rounded-full mb-5 sm:mb-7">
              Available on iOS
            </span>
            <h1 className="text-5xl sm:text-6xl xl:text-7xl font-extrabold leading-[1.05] tracking-tight mb-5 sm:mb-6">
              Track your
              <br />
              <span className="text-[#6C63FF]">lifts.</span>
            </h1>
            <p className="text-white/55 text-base sm:text-lg lg:text-xl leading-relaxed max-w-sm sm:max-w-[440px] mx-auto lg:mx-0 mb-8 sm:mb-10">
              Progress is the minimalist workout logger built for people who
              actually care about getting stronger. No noise. No subscriptions.
              Just your data.
            </p>
            <div className="flex justify-center lg:justify-start">
              <a
                href={APP_STORE_URL}
                className="inline-flex items-center gap-2.5 sm:gap-3 bg-white text-black font-bold px-5 sm:px-7 py-3 sm:py-3.5 rounded-2xl text-sm sm:text-[15px] hover:bg-white/90 active:scale-95 transition-all shadow-xl shadow-white/5"
              >
                <AppleIcon className="w-4 h-4 sm:w-5 sm:h-5 shrink-0" />
                Download on the App Store
              </a>
            </div>
          </div>

          {/* Phone mockup */}
          <div className="flex justify-center">
            <div className="relative">
              <div className="absolute inset-0 bg-[#6C63FF]/20 rounded-[50px] blur-3xl scale-110 pointer-events-none" />
              <div className="relative w-[220px] sm:w-[260px] lg:w-[300px] rounded-[40px] sm:rounded-[44px] border-2 border-white/10 overflow-hidden shadow-2xl shadow-black/70">
                <Image
                  src="/screenshots/HomePage.PNG"
                  alt="Progress app — home screen"
                  width={390}
                  height={844}
                  className="w-full h-auto"
                  priority
                />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── Demo Video ──────────────────────────────────────────── */}
      <section className="py-20 sm:py-28 px-5">
        <div className="max-w-5xl mx-auto text-center">
          <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold mb-3">See it in action</h2>
          <p className="text-white/50 text-base sm:text-lg mb-10 sm:mb-14 max-w-xs sm:max-w-sm mx-auto">
            Log a workout, check your progress, and review your history — all in seconds.
          </p>
          <div className="relative inline-block">
            <div className="absolute inset-0 bg-[#6C63FF]/15 rounded-[50px] blur-3xl scale-110 pointer-events-none" />
            <div className="relative w-[220px] sm:w-[260px] lg:w-[300px] rounded-[40px] sm:rounded-[44px] border-2 border-white/10 overflow-hidden shadow-2xl shadow-black/70 mx-auto">
              <video
                src="/video/AppleDemoProgressWorkoutLogger.mp4"
                autoPlay
                muted
                loop
                playsInline
                className="w-full h-auto"
              />
            </div>
          </div>
        </div>
      </section>

      {/* ── Features ────────────────────────────────────────────── */}
      <section className="py-20 sm:py-28 px-5">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-10 sm:mb-16">
            <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold mb-3 sm:mb-4">
              Everything you need,
              <br className="hidden sm:block" /> nothing you don&apos;t.
            </h2>
            <p className="text-white/50 text-base sm:text-lg max-w-xs sm:max-w-md mx-auto">
              Designed around how serious lifters actually train.
            </p>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
            {features.map((f) => (
              <div
                key={f.title}
                className="bg-[#141414] border border-white/[0.06] rounded-2xl p-5 sm:p-6 hover:border-[#6C63FF]/40 hover:bg-[#6C63FF]/5 transition-all duration-300 group"
              >
                <div className="w-10 h-10 sm:w-12 sm:h-12 bg-[#6C63FF]/15 group-hover:bg-[#6C63FF]/25 rounded-xl sm:rounded-2xl flex items-center justify-center text-xl sm:text-2xl mb-4 sm:mb-5 transition-colors">
                  {f.emoji}
                </div>
                <h3 className="text-sm sm:text-[15px] font-semibold mb-1.5 sm:mb-2">{f.title}</h3>
                <p className="text-white/45 text-xs sm:text-sm leading-relaxed">{f.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── Screenshots ─────────────────────────────────────────── */}
      <section className="py-20 sm:py-28">
        <div className="text-center px-5 mb-10 sm:mb-14">
          <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold mb-3">
            Every detail, beautifully displayed.
          </h2>
          <p className="text-white/50 text-base sm:text-lg max-w-xs sm:max-w-md mx-auto">
            A clean interface that stays focused on your training data.
          </p>
        </div>
        <ScreenshotCarousel />
      </section>

      {/* ── Footer ──────────────────────────────────────────────── */}
      <footer className="border-t border-white/5 py-8 sm:py-10 text-center px-5">
        <p className="text-white/30 text-xs sm:text-sm mb-3">
          © {new Date().getFullYear()} Progress. All rights reserved.
        </p>
        <div className="flex items-center justify-center gap-4 sm:gap-6">
          <Link href="/privacy-policy" className="text-white/30 hover:text-white/60 text-xs sm:text-sm transition-colors">
            Privacy Policy
          </Link>
          <span className="text-white/15 text-xs">•</span>
          <Link href="/terms-of-service" className="text-white/30 hover:text-white/60 text-xs sm:text-sm transition-colors">
            Terms of Service
          </Link>
        </div>
      </footer>

    </main>
  );
}

function AppleIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
      <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
    </svg>
  );
}

import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Terms of Service — Progress",
  description: "Terms of Service for the Progress workout logging app.",
};

export default function TermsOfService() {
  return (
    <main className="bg-[#0E0E0E] text-white min-h-screen">
      <nav className="flex items-center justify-between px-5 sm:px-10 py-4 border-b border-white/5">
        <Link href="/" className="text-base sm:text-lg font-bold tracking-tight hover:text-white/80 transition-colors">
          Progress
        </Link>
        <Link href="/" className="text-sm text-white/50 hover:text-white transition-colors">
          ← Back
        </Link>
      </nav>

      <div className="max-w-3xl mx-auto px-5 sm:px-8 py-14 sm:py-20">
        <h1 className="text-3xl sm:text-4xl font-extrabold mb-3 tracking-tight">Terms of Service</h1>
        <p className="text-white/40 text-sm mb-12">Last updated: June 26, 2025</p>

        <div className="space-y-10 text-white/75 leading-relaxed">

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">1. Acceptance of Terms</h2>
            <p>
              By downloading, installing, or using the Progress workout logging application (the "App"),
              you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these
              Terms, do not use the App.
            </p>
            <p className="mt-3">
              We reserve the right to modify these Terms at any time. Continued use of the App after
              changes are posted constitutes your acceptance of the revised Terms.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">2. Use of the App</h2>
            <p className="mb-3">
              Progress is a personal workout logging tool. You may use it to log exercises, track
              progress over time, and organize your training data. You agree to use the App only for
              lawful, personal, non-commercial purposes.
            </p>
            <p className="mb-3">You agree that you will not:</p>
            <ul className="list-disc list-inside space-y-2 text-white/70">
              <li>Attempt to reverse engineer, decompile, or modify the App</li>
              <li>Use the App in any way that could damage, disable, or impair its functionality</li>
              <li>Attempt to gain unauthorized access to our systems or other users&apos; data</li>
              <li>Use the App to violate any applicable law or regulation</li>
            </ul>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">3. Accounts</h2>
            <p className="mb-3">
              To use Progress, you must sign in using your Google account. You are responsible for
              maintaining the security of your account and for all activity that occurs under it.
            </p>
            <p>
              We reserve the right to suspend or terminate your account if we believe you have
              violated these Terms or engaged in conduct harmful to other users or the App.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">4. Your Data</h2>
            <p className="mb-3">
              You retain full ownership of the workout data you enter into Progress. By using the App,
              you grant us a limited license to store and process your data solely for the purpose of
              providing and improving the App&apos;s services to you.
            </p>
            <p>
              We will not sell your data or use it for advertising. For full details on how we handle
              your data, see our{" "}
              <Link href="/privacy-policy" className="text-[#6C63FF] hover:underline">
                Privacy Policy
              </Link>.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">5. Health and Fitness Disclaimer</h2>
            <p className="mb-3">
              <strong className="text-white">Progress is a data logging tool, not a medical or fitness
              advisory service.</strong> The information and data within the App are intended solely
              to help you record and review your own training activity.
            </p>
            <p className="mb-3">
              Nothing in the App constitutes medical advice, fitness advice, or a recommendation to
              perform any specific exercise or training program. Always consult a qualified healthcare
              provider or certified fitness professional before beginning any exercise program,
              especially if you have a pre-existing medical condition or injury.
            </p>
            <p>
              We are not responsible for any injury, illness, or adverse health outcome that may
              result from physical activity you undertake while using or after using this App.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">6. Intellectual Property</h2>
            <p>
              All content, design, code, trademarks, and other materials associated with Progress —
              excluding your personal workout data — are owned by us and protected by applicable
              intellectual property laws. You may not reproduce, distribute, or create derivative works
              based on any part of the App without our prior written permission.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">7. Third-Party Services</h2>
            <p>
              Progress uses third-party services including Google Sign-In and Supabase. Your use of
              those services is governed by their respective terms of service. We are not responsible
              for the actions, content, or practices of these third parties.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">8. Disclaimer of Warranties</h2>
            <p>
              The App is provided <strong className="text-white">"as is"</strong> and{" "}
              <strong className="text-white">"as available"</strong> without warranties of any kind,
              either express or implied. We do not warrant that the App will be uninterrupted,
              error-free, or free of viruses or other harmful components. We make no guarantees
              regarding the accuracy, completeness, or reliability of any data stored in the App.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">9. Limitation of Liability</h2>
            <p>
              To the fullest extent permitted by applicable law, we shall not be liable for any
              indirect, incidental, special, consequential, or punitive damages — including loss of
              data, loss of profits, or personal injury — arising from your use of or inability to
              use the App, even if we have been advised of the possibility of such damages. Our total
              liability to you for any claim shall not exceed the amount you paid to use the App in
              the twelve months preceding the claim, or $10 USD, whichever is greater.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">10. Termination</h2>
            <p>
              You may stop using the App at any time. You may also request deletion of your account
              and data as described in our Privacy Policy. We reserve the right to suspend or
              terminate your access to the App at any time, with or without cause, and with or without
              notice. Upon termination, your right to use the App ceases immediately.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">11. Governing Law</h2>
            <p>
              These Terms are governed by and construed in accordance with the laws of the State of
              California, without regard to its conflict of law principles. Any disputes arising under
              these Terms shall be subject to the exclusive jurisdiction of the courts located in
              California.
            </p>
          </section>

        </div>
      </div>

      <footer className="border-t border-white/5 py-8 text-center px-5">
        <p className="text-white/25 text-xs">© {new Date().getFullYear()} Progress. All rights reserved.</p>
      </footer>
    </main>
  );
}

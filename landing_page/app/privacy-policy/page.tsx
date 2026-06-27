import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Privacy Policy — Progress",
  description: "Privacy Policy for the Progress workout logging app.",
};

export default function PrivacyPolicy() {
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
        <h1 className="text-3xl sm:text-4xl font-extrabold mb-3 tracking-tight">Privacy Policy</h1>
        <p className="text-white/40 text-sm mb-12">Last updated: June 26, 2025</p>

        <div className="space-y-10 text-white/75 leading-relaxed">

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">1. Introduction</h2>
            <p>
              Welcome to Progress ("we," "us," or "our"). We are committed to protecting your personal
              information and your right to privacy. This Privacy Policy explains what information we
              collect, how we use it, and what rights you have in relation to it when you use our iOS
              workout logging application (the "App").
            </p>
            <p className="mt-3">
              By using Progress, you agree to the collection and use of information in accordance with
              this policy. If you do not agree with its terms, please discontinue use of the App.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">2. Information We Collect</h2>
            <p className="mb-4">We collect the following categories of information:</p>

            <h3 className="font-semibold text-white/90 mb-2">Account Information</h3>
            <p className="mb-4">
              When you sign in with Google, we receive your name, email address, and profile picture
              from your Google account. This information is used solely to create and identify your
              account within the App.
            </p>

            <h3 className="font-semibold text-white/90 mb-2">Workout Data</h3>
            <p className="mb-4">
              Progress stores the workout data you create, including exercise names, groups and folders,
              workout logs (sets, reps, weight, duration, and date), and any organizational structure
              you build within the App. This data belongs to you and is stored securely on our servers.
            </p>

            <h3 className="font-semibold text-white/90 mb-2">Usage Data</h3>
            <p>
              We may collect basic, anonymized information about how you interact with the App, such
              as feature usage frequency and crash reports. This data does not identify you personally
              and is used only to improve the App&apos;s stability and performance.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">3. How We Use Your Information</h2>
            <p className="mb-3">We use the information we collect to:</p>
            <ul className="list-disc list-inside space-y-2 text-white/70">
              <li>Create and manage your account</li>
              <li>Store, sync, and retrieve your workout data across sessions</li>
              <li>Provide, maintain, and improve the functionality of the App</li>
              <li>Diagnose technical issues and fix bugs</li>
              <li>Respond to your support requests or inquiries</li>
              <li>Comply with applicable legal obligations</li>
            </ul>
            <p className="mt-4">
              We do not use your workout data for advertising, do not sell your data to third parties,
              and do not use your data to train machine learning models.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">4. Data Storage and Security</h2>
            <p className="mb-3">
              Your data is stored using <strong className="text-white">Supabase</strong>, a secure,
              cloud-based database platform. All data is encrypted in transit using TLS and at rest
              using industry-standard encryption.
            </p>
            <p>
              While we take reasonable measures to protect your information, no method of electronic
              storage or transmission over the internet is 100% secure. We cannot guarantee absolute
              security, and you use the App at your own risk.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">5. Third-Party Services</h2>
            <p className="mb-3">Progress uses the following third-party services:</p>
            <ul className="list-disc list-inside space-y-2 text-white/70">
              <li>
                <strong className="text-white/90">Google Sign-In</strong> — used for authentication.
                Your use of Google Sign-In is subject to{" "}
                <a href="https://policies.google.com/privacy" target="_blank" rel="noopener noreferrer" className="text-[#6C63FF] hover:underline">
                  Google&apos;s Privacy Policy
                </a>.
              </li>
              <li>
                <strong className="text-white/90">Supabase</strong> — used for database storage and
                authentication. Subject to{" "}
                <a href="https://supabase.com/privacy" target="_blank" rel="noopener noreferrer" className="text-[#6C63FF] hover:underline">
                  Supabase&apos;s Privacy Policy
                </a>.
              </li>
            </ul>
            <p className="mt-4">
              We are not responsible for the privacy practices of these third-party services.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">6. Your Data Rights</h2>
            <p className="mb-3">You have the right to:</p>
            <ul className="list-disc list-inside space-y-2 text-white/70">
              <li><strong className="text-white/90">Access</strong> — request a copy of the data we hold about you</li>
              <li><strong className="text-white/90">Correction</strong> — update inaccurate or incomplete information</li>
              <li><strong className="text-white/90">Deletion</strong> — delete your account and all associated data directly from within the App, or by contacting us</li>
              <li><strong className="text-white/90">Portability</strong> — request an export of your workout data</li>
            </ul>
            <p className="mt-4">
              To exercise any of these rights, please contact us at the email address listed below.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">7. Data Retention</h2>
            <p>
              We retain your account and workout data for as long as your account is active. If you
              delete your account, all associated data is permanently removed from our servers within
              30 days, except where we are required to retain it for legal or compliance purposes.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">8. Children&apos;s Privacy</h2>
            <p>
              Progress is not directed to children under the age of 13. We do not knowingly collect
              personal information from children under 13. If you believe we have inadvertently
              collected such information, please contact us immediately and we will take steps to
              delete it.
            </p>
          </section>

          <section>
            <h2 className="text-lg sm:text-xl font-semibold text-white mb-3">9. Changes to This Policy</h2>
            <p>
              We may update this Privacy Policy from time to time. We will notify you of significant
              changes by updating the "Last updated" date at the top of this page. Your continued use
              of the App after changes are posted constitutes your acceptance of the revised policy.
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

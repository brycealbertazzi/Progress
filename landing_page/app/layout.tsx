import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"], variable: "--font-inter" });

export const metadata: Metadata = {
  title: "Progress — Track Your Lifts",
  description:
    "The minimalist workout logger built for people who care about getting stronger. No noise, no subscriptions — just your data.",
  openGraph: {
    title: "Progress — Track Your Lifts",
    description:
      "The minimalist workout logger built for people who care about getting stronger.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={`${inter.variable} font-sans antialiased`}>
        {children}
      </body>
    </html>
  );
}

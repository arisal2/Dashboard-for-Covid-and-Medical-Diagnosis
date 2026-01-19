import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Covid-19 Dashboard",
  description: "Modern Dashboard for Covid-19 Visualizations",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased bg-slate-50 text-slate-900">
        {children}
      </body>
    </html>
  );
}

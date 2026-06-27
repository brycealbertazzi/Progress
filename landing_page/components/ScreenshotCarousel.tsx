import Image from "next/image";

const screenshots = [
  { src: "/screenshots/HomePage.PNG", label: "Home" },
  { src: "/screenshots/ExerciseView.PNG", label: "Exercise logs" },
  { src: "/screenshots/GraphView.PNG", label: "Progress graph" },
  { src: "/screenshots/CalendayDayView.PNG", label: "Calendar view" },
  { src: "/screenshots/FolderView.png", label: "Folders" },
  { src: "/screenshots/ExerciseCreateModal.PNG", label: "Add exercise" },
];

export default function ScreenshotCarousel() {
  return (
    <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 sm:gap-6 lg:gap-8 px-4 sm:px-8 lg:px-16 max-w-6xl mx-auto">
      {screenshots.map((s) => (
        <div key={s.src} className="flex flex-col items-center">
          <div className="w-full rounded-[28px] sm:rounded-[36px] border-2 border-white/10 overflow-hidden shadow-xl shadow-black/60">
            <Image
              src={s.src}
              alt={s.label}
              width={390}
              height={844}
              className="w-full h-auto"
            />
          </div>
          <p className="text-white/35 text-[11px] sm:text-xs mt-2 sm:mt-3 font-medium tracking-wide">
            {s.label}
          </p>
        </div>
      ))}
    </div>
  );
}

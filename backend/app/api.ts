import { api } from "encore.dev/api";

export interface VersionResponse {
    latestVersion: string;
    downloadUrl: string;
    releaseNotes: string;
    forceUpdate: boolean;
}

export const version = api(
    { expose: true, method: "GET", path: "/app/version" },
    async (): Promise<VersionResponse> => {
        return {
            latestVersion: "1.0.0",
            downloadUrl: "https://github.com/rey109/carego-healthcare-mobile-prototype/releases/latest/download/carego-release.apk",
            releaseNotes: "Versi pertama CAREGO - Semua fitur dasar telah tersedia.",
            forceUpdate: false
        };
    }
);

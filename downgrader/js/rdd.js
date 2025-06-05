/*
    rdd - https://github.com/latte-soft/rdd
    Copyright (C) 2024-2025 Latte Softworks <latte.to> | MIT License
*/

const basePath = window.location.href.split("?")[0];
const usageMsg = `[*] USAGE: Enter the required version in the Version Hash box. Supported binary types: WindowsPlayer, WindowsStudio64, MacPlayer, MacStudio.`;

const hostPath = "https://setup-aws.rbxcdn.com"; // Only AWS mirror has proper CORS config

// Root extract locations for Windows manifests
const extractRoots = {
    player: {
        "RobloxApp.zip": "",
        "redist.zip": "",
        "shaders.zip": "shaders/",
        "ssl.zip": "ssl/",
        "WebView2.zip": "",
        "WebView2RuntimeInstaller.zip": "WebView2RuntimeInstaller/",
        "content-avatar.zip": "content/avatar/",
        "content-configs.zip": "content/configs/",
        "content-fonts.zip": "content/fonts/",
        "content-sky.zip": "content/sky/",
        "content-sounds.zip": "content/sounds/",
        "content-textures2.zip": "content/textures/",
        "content-models.zip": "content/models/",
        "content-platform-fonts.zip": "PlatformContent/pc/fonts/",
        "content-platform-dictionaries.zip": "PlatformContent/pc/shared_compression_dictionaries/",
        "content-terrain.zip": "PlatformContent/pc/terrain/",
        "content-textures3.zip": "PlatformContent/pc/textures/",
        "extracontent-luapackages.zip": "ExtraContent/LuaPackages/",
        "extracontent-translations.zip": "ExtraContent/translations/",
        "extracontent-models.zip": "ExtraContent/models/",
        "extracontent-textures.zip": "ExtraContent/textures/",
        "extracontent-places.zip": "ExtraContent/places/"
    },
    studio: {
        "RobloxStudio.zip": "",
        "RibbonConfig.zip": "RibbonConfig/",
        "redist.zip": "",
        "Libraries.zip": "",
        "LibrariesQt5.zip": "",
        "WebView2.zip": "",
        "WebView2RuntimeInstaller.zip": "",
        "shaders.zip": "shaders/",
        "ssl.zip": "ssl/",
        "Qml.zip": "Qml/",
        "Plugins.zip": "Plugins/",
        "StudioFonts.zip": "StudioFonts/",
        "BuiltInPlugins.zip": "BuiltInPlugins/",
        "ApplicationConfig.zip": "ApplicationConfig/",
        "BuiltInStandalonePlugins.zip": "BuiltInStandalonePlugins/",
        "content-qt_translations.zip": "content/qt_translations/",
        "content-sky.zip": "content/sky/",
        "content-fonts.zip": "content/fonts/",
        "content-avatar.zip": "content/avatar/",
        "content-models.zip": "content/models/",
        "content-sounds.zip": "content/sounds/",
        "content-configs.zip": "content/configs/",
        "content-api-docs.zip": "content/api_docs/",
        "content-textures2.zip": "content/textures/",
        "content-studio_svg_textures.zip": "content/studio_svg_textures/",
        "content-platform-fonts.zip": "PlatformContent/pc/fonts/",
        "content-platform-dictionaries.zip": "PlatformContent/pc/shared_compression_dictionaries/",
        "content-terrain.zip": "PlatformContent/pc/terrain/",
        "content-textures3.zip": "PlatformContent/pc/textures/",
        "extracontent-translations.zip": "ExtraContent/translations/",
        "extracontent-luapackages.zip": "ExtraContent/LuaPackages/",
        "extracontent-textures.zip": "ExtraContent/textures/",
        "extracontent-scripts.zip": "ExtraContent/scripts/",
        "extracontent-models.zip": "ExtraContent/models/"
    }
};

const binaryTypes = {
    WindowsPlayer: { blobDir: "/" },
    WindowsStudio64: { blobDir: "/" },
    MacPlayer: { blobDir: "/mac/" },
    MacStudio: { blobDir: "/mac/" }
};

const urlParams = new URLSearchParams(window.location.search);
const consoleText = document.getElementById("consoleText");
const downloadForm = document.getElementById("downloadForm");
const heroSection = document.querySelector(".hero-section");
const footer = document.querySelector("footer");

function getPermLink() {
    const channelName = downloadForm.channel.value.trim() || downloadForm.channel.placeholder;
    let queryString = `?channel=${encodeURIComponent(channelName)}&binaryType=${encodeURIComponent(downloadForm.binaryType.value)}`;

    const versionHash = downloadForm.version.value.trim();
    if (versionHash) {
        queryString += `&version=${encodeURIComponent(versionHash)}`;
    }

    const compressZip = downloadForm.compressZip.checked;
    const compressionLevel = downloadForm.compressionLevel.value;
    if (compressZip) {
        queryString += `&compressZip=true&compressionLevel=${compressionLevel}`;
    }

    return basePath + queryString;
}

function downloadFromForm() {
    window.open(getPermLink(), "_self");
}

function copyPermLink() {
    navigator.clipboard.writeText(getPermLink())
        .then(() => {
            log("Permanent link copied to clipboard!");
        })
        .catch(() => {
            log("[!] Failed to copy permanent link.");
        });
}

function scrollToBottom() {
    window.scrollTo({
        top: document.body.scrollHeight,
        behavior: "smooth"
    });
}

function escHtml(originalText) {
    return originalText
        .replace(/&/g, "&")
        .replace(/</g, "<")
        .replace(/>/g, ">")
        .replace(/'/g, "'")
        .replace(/ /g, " ")
        .replace(/\n/g, "<br>");
}

function log(msg = "", end = "\n", autoScroll = true) {
    if (consoleText) {
        consoleText.classList.add("visible"); // Show output in full-screen
        consoleText.innerHTML += escHtml(msg) + end;
        if (autoScroll) {
            scrollToBottom();
        }
    } else {
        console.warn("Console output element not found:", msg);
    }
}

function hideContentDuringDownload() {
    if (heroSection) heroSection.classList.add("hidden");
    if (footer) footer.classList.add("hidden");
}

function showContentAfterDownload() {
    if (heroSection) heroSection.classList.remove("hidden");
    if (footer) footer.classList.remove("hidden");
}

function downloadBinaryFile(fileName, data, mimeType = "application/zip") {
    const blob = new Blob([data], { type: mimeType });
    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = fileName;
    link.style.display = "none";

    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(link.href);

    log(`[+] Downloaded ${fileName}`);
    showContentAfterDownload(); // Restore content after download
}

function requestBinary(url, callback) {
    const httpRequest = new XMLHttpRequest();
    httpRequest.open("GET", url, true);
    httpRequest.responseType = "arraybuffer";

    httpRequest.onload = function () {
        const statusCode = httpRequest.status;
        if (statusCode !== 200) {
            log(`[!] Binary request error (${statusCode}) @ ${url}`);
            showContentAfterDownload(); // Restore content on error
            return;
        }

        const arrayBuffer = httpRequest.response;
        if (!arrayBuffer) {
            log(`[!] Binary request error (${statusCode}) @ ${url} - Failed to get binary ArrayBuffer`);
            showContentAfterDownload(); // Restore content on error
            return;
        }

        callback(arrayBuffer, statusCode);
    };

    httpRequest.onerror = function (e) {
        log(`[!] Binary request error @ ${url} - ${e}`);
        showContentAfterDownload(); // Restore content on error
    };

    httpRequest.send();
}

function getQuery(queryString) {
    return urlParams.get(queryString) || null;
}

function main() {
    if (!downloadForm || !consoleText) {
        log("[!] Error: Required DOM elements (form or console) not found. Please check the HTML structure.");
        return;
    }

    let channel = getQuery("channel");
    let version = getQuery("version") || getQuery("guid");
    let binaryType = getQuery("binaryType");
    let blobDir = getQuery("blobDir");
    let compressZip = getQuery("compressZip");
    let compressionLevel = getQuery("compressionLevel");
    let channelPath;
    let versionPath;
    let binExtractRoots;
    let zip;

    if (window.location.search === "") {
        log(usageMsg, "\n", false);
        return;
    }

    // Process query parameters
    if (channel) {
        channel = channel === "LIVE" ? channel : channel.toLowerCase();
    } else {
        channel = "LIVE";
    }

    channelPath = channel === "LIVE" ? hostPath : `${hostPath}/channel/${channel}`;

    if (version) {
        version = version.toLowerCase();
        if (!version.startsWith("version-")) {
            version = "version-" + version;
        }
    }

    if (blobDir && blobDir !== "") {
        blobDir = blobDir.startsWith("/") ? blobDir : "/" + blobDir;
        blobDir = blobDir.endsWith("/") ? blobDir : blobDir + "/";
    }

    if (compressZip) {
        if (compressZip !== "true" && compressZip !== "false") {
            log(`[!] Error: The \`compressZip\` query must be "true" or "false", got "${compressZip}"`);
            return;
        }
        compressZip = compressZip === "true";
    } else {
        compressZip = downloadForm.compressZip.checked;
    }

    if (compressionLevel) {
        try {
            compressionLevel = parseInt(compressionLevel);
            if (compressionLevel < 1 || compressionLevel > 9) {
                log(`[!] Error: The \`compressionLevel\` query must be between 1 and 9, got ${compressionLevel}`);
                return;
            }
        } catch (err) {
            log(`[!] Error: Failed to parse \`compressionLevel\` query: ${err}`);
            return;
        }
    } else {
        compressionLevel = parseInt(downloadForm.compressionLevel.value);
    }

    if (!binaryType) {
        log("[!] Error: Missing required `binaryType` query. See usage below:", "\n\n");
        log(usageMsg, "\n", false);
        return;
    }

    if (!(binaryType in binaryTypes)) {
        log(`[!] Error: \`binaryType\` "${binaryType}" not supported. See below for supported types:`, "\n\n");
        log(usageMsg);
        return;
    }

    const binaryTypeObject = binaryTypes[binaryType];
    blobDir = blobDir || binaryTypeObject.blobDir;

    if (version) {
        fetchManifest();
    } else {
        const binaryTypeEncoded = escHtml(binaryType);
        const channelNameEncoded = escHtml(channel);
        const clientSettingsUrl = `https://clientsettings.roblox.com/v2/client-version/${binaryTypeEncoded}/channel/${channelNameEncoded}`;
        log(`Copy the version hash (e.g., "version-xxxxxxxxxxxxxxxx") from the page below and paste it into the "Version Hash" field:\n`);
        consoleText.innerHTML += `<a target="_blank" href="${clientSettingsUrl}">${clientSettingsUrl}</a><br><br>`;
        downloadForm.channel.value = channelNameEncoded;
        downloadForm.binaryType.value = binaryTypeEncoded;
        downloadForm.compressZip.checked = compressZip;
        downloadForm.compressionLevel.value = compressionLevel;
    }

    async function fetchManifest() {
        hideContentDuringDownload(); // Hide hero section and footer
        versionPath = `${channelPath}${blobDir}${version}-`;

        if (binaryType === "MacPlayer" || binaryType === "MacStudio") {
            const zipFileName = binaryType === "MacPlayer" ? "RobloxPlayer.zip" : "RobloxStudioApp.zip";
            log(`[+] Fetching zip archive for BinaryType "${binaryType}" (${zipFileName})`);
            const outputFileName = `${channel}-${binaryType}-${version}.zip`;
            log(`[+] Downloading ${outputFileName}...`, "");
            requestBinary(versionPath + zipFileName, function (zipData) {
                log("done!");
                downloadBinaryFile(outputFileName, zipData);
            });
        } else {
            log(`[+] Fetching rbxPkgManifest for ${version}@${channel}...`);
            let manifestBody;
            try {
                let resp = await fetch(versionPath + "rbxPkgManifest.txt");
                if (!resp.ok) {
                    channelPath = `${hostPath}/channel/common`;
                    versionPath = `${channelPath}${blobDir}${version}-`;
                    resp = await fetch(versionPath + "rbxPkgManifest.txt");
                }

                if (!resp.ok) {
                    log(`[!] Failed to fetch rbxPkgManifest: (status: ${resp.status}, err: ${(await resp.text()) || "<failed to get response from server>"})`);
                    showContentAfterDownload();
                    return;
                }
                manifestBody = await resp.text();
            } catch (err) {
                log(`[!] Error fetching rbxPkgManifest: ${err}`);
                showContentAfterDownload();
                return;
            }
            downloadZipsFromManifest(manifestBody);
        }
    }

    async function downloadZipsFromManifest(manifestBody) {
        const pkgManifestLines = manifestBody.split("\n").map(line => line.trim());
        if (pkgManifestLines[0] !== "v0") {
            log(`[!] Error: Unknown rbxPkgManifest format version; expected "v0", got "${pkgManifestLines[0]}"`);
            showContentAfterDownload();
            return;
        }

        binExtractRoots = pkgManifestLines.includes("RobloxApp.zip") ? extractRoots.player : extractRoots.studio;
        if (pkgManifestLines.includes("RobloxApp.zip") && binaryType === "WindowsStudio64") {
            log(`[!] Error: BinaryType \`${binaryType}\` given, but "RobloxApp.zip" found in manifest!`);
            showContentAfterDownload();
            return;
        }
        if (pkgManifestLines.includes("RobloxStudio.zip") && binaryType === "WindowsPlayer") {
            log(`[!] Error: BinaryType \`${binaryType}\` given, but "RobloxStudio.zip" found in manifest!`);
            showContentAfterDownload();
            return;
        }

        log(`[+] Fetching blobs for BinaryType \`${binaryType}\`...`);
        zip = new JSZip();
        zip.file("AppSettings.xml", `<?xml version="1.0" encoding="UTF-8"?>
<Settings>
    <ContentFolder>content</ContentFolder>
    <BaseUrl>http://www.roblox.com</BaseUrl>
</Settings>
`);

        let threadsLeft = 0;
        function doneCallback() {
            threadsLeft--;
        }

        for (const pkgManifestLine of pkgManifestLines) {
            if (!pkgManifestLine.endsWith(".zip")) {
                continue;
            }
            threadsLeft++;
            downloadPackage(pkgManifestLine, doneCallback);
        }

        function checkIfNoThreadsLeft() {
            if (threadsLeft > 0) {
                setTimeout(checkIfNoThreadsLeft, 250);
                return;
            }
            const outputFileName = `${channel}-${binaryType}-${version}.zip`;
            log();
            if (compressZip) {
                log(`[!] NOTE: Compressing final zip (level ${compressionLevel}/9), this may take a moment`);
            }
            log(`[+] Exporting assembled zip file "${outputFileName}"...`, "");
            zip.generateAsync({
                type: "arraybuffer",
                compression: compressZip ? "DEFLATE" : "STORE",
                compressionOptions: { level: compressionLevel }
            }).then(function (outputZipData) {
                zip = null;
                log("done!");
                downloadBinaryFile(outputFileName, outputZipData);
            }).catch(err => {
                log(`[!] Error generating zip: ${err}`);
                showContentAfterDownload();
            });
        }

        checkIfNoThreadsLeft();
    }

    async function downloadPackage(packageName, doneCallback) {
        log(`[+] Fetching "${packageName}"...`);
        const blobUrl = versionPath + packageName;
        requestBinary(blobUrl, async function (blobData) {
            if (!(packageName in binExtractRoots)) {
                log(`[*] Package "${packageName}" not in extraction roots for \`${binaryType}\`, skipping extraction! (This may make the zip incomplete.)`);
                zip.file(packageName, blobData);
                log(`[+] Moved "${packageName}" to root folder`);
                doneCallback();
                return;
            }

            log(`[+] Extracting "${packageName}"...`);
            const extractRootFolder = binExtractRoots[packageName];
            try {
                const packageZip = await JSZip.loadAsync(blobData);
                const fileGetPromises = [];
                packageZip.forEach(function (path, object) {
                    if (path.endsWith("\\")) {
                        return;
                    }
                    const fixedPath = path.replace(/\\/g, "/");
                    fileGetPromises.push(object.async("arraybuffer").then(data => {
                        zip.file(extractRootFolder + fixedPath, data);
                    }));
                });
                await Promise.all(fileGetPromises);
                log(`[+] Extracted "${packageName}"! (Packages left: ${threadsLeft - 1})`);
                doneCallback();
            } catch (err) {
                log(`[!] Error extracting "${packageName}": ${err}`);
                doneCallback();
                showContentAfterDownload();
            }
        });
    }
}

// Run main when DOM is fully loaded
document.addEventListener("DOMContentLoaded", main);

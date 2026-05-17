# Info
These presets are made to proxy only those domains and CIDRs that are blocked in Russia, while directing domestic and non-restricted traffic to not hog up server bandwidth.\
Even though I initially created this repo to contain **v2ray/xray** .json-formatted routing presets, I also made ones for **sing-box**.

Made based on .dat files from [v2fly](https://github.com/v2fly/domain-list-community) and [runetfreedom](https://github.com/runetfreedom/russia-v2ray-rules-dat) repos.

## Client apps
* **v2ray/xray** — [v2rayN](https://github.com/2dust/v2rayN) (Linux, Win, macOS), [v2rayNG](https://github.com/2dust/v2rayNG) (Android), [INCY](https://incy.cc) (Android, iOS, Linux, Win, macOS), [Streisand](https://apps.apple.com/us/app/streisand/id6450534064) (iOS, macOS)
* **sing-box** — [NyameBox](https://github.com/qr243vbi/nekobox) (Linux, Win), [Throne](https://github.com/throneproj/Throne) (Linux, Win, macOS), [NekoBox](https://github.com/starifly/NekoBoxForAndroid) (Android), [husi](https://github.com/xchacha20-poly1305/husi) (Android)

## Presets

| Preset | Description
| :--- | :--- 
| **blocked_only** | Proxy only known blocked domains and CIDRs
| **except_ru** | Proxy all traffic except Russian domains and CIDRs
| **all** | Proxy all traffic

### Raw links (v2ray/xray presets)
* **blocked_only**: https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/rules/blocked_only.json
* **except_ru**: https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/rules/except_ru.json
* **all**: https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/rules/all.json

### Raw links (sing-box presets)
* **blocked_only**: https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/rules/blocked_only-singbox.json
* **except_ru**: https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/rules/except_ru-singbox.json
* **all**: https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/rules/all-singbox.json

Note that **v2ray/xray** and **sing-box** rules *might have* differences to some non-critical degree, but I usually try to keep parity between them when updating.

---

# Setting up
This section is completely optional, since it is generally easy to import and use routing presets. However, I did make some basic guides, just in case someone would need them.

Be wary that most apps already have means of downloading pre-determined routing presets, therefore you generally do not need my custom presets.\
If you do need them/custom ones, however (your app isn't one of the lucky few, i.e.), continue below.

## v2rayN

### 1. Download geofiles and default presets
1. Open **Settings** > **Regional presets setting**, select **Russia**.
2. When geofiles and presets finish downloading, either use them or proceed below to import presets from this repo.

### 2. Configure geofiles source
1. Open **Settings** > **Option Setting** > **v2rayN settings**.
2. In **Geo files source, sing-box ruleset files source, and Routing rules source** dropdowns, select `runetfreedom/russia-v2ray-rules-dat`.

### 3. Import presets
1. Open **Settings** > **Routing Setting**.
2. Click **Add** and fill boxes: **Remark** - any name, **Domain Strategy** - choose **IPOnDemand**, **URL** - paste the raw link of the chosen preset.
3. Click **Import rules from subscription url** and select **Append**.\
If pasting from URL won't work, copy all .json contents from the raw link, and click **Import from clipboard**, then **Append**.

### 4. Use presets
1. In the lower center box of the app, select a routing preset.
2. Enable either **Tun Mode** (creates a TUNnel interface, works across whole system) or **System Proxy** (modifies system proxy settings, works in browsers only).

## NyameBox

### 1. Download geofiles and default presets
1. Open **Routing** > **Download Profiles**, select one of the presets for **Russia**.
2. When geofiles and presets finish downloading, either use them or proceed below to import presets from this repo.

### 2. Import presets
1. Open **Routing** > **Edit Routing Profiles** > **Route**, click **New**.
2. Set **Default outbound** to **Direct** if you chose the `blocked_only` preset, or **Proxy** elsewise.
3. In **Advanced**, click on **Import JSON** and paste the .json contents of the chosen preset.

### 3. Use presets
1. Open **Routing** and select a routing preset.
2. Enable either **Tun Mode** (creates a TUNnel interface, works across whole system) or **System Proxy** (modifies system proxy settings, works in browsers only).

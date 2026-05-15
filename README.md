# Info
These presets are made to proxy only those domains and CIDRs that are blocked in Russia, while directing domestic and non-restricted traffic to not hog up server bandwidth.\
Even though I initially created this repo to contain **v2ray/xray** .json-formatted routing presets, I also made ones for **sing-box**.

These presets are made based on .dat files from [v2fly](https://github.com/v2fly/domain-list-community) repo.

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
First, you must download the specific .dat files for the region.
1. Open **Settings** > **Regional presets setting**.
2. Select **Russia** from the list. This downloads the necessary `.dat` files.
3. **Note:** This will create default profiles. You can use them, or proceed to the next steps to **overwrite/delete** them with my (or your) custom settings.

### 2. Configure geofiles source (optional, but check if it's set correctly anyways)
1. Open **Settings** > **Option Setting** > **v2rayN settings**.
2. Locate the **Geo files source** dropdown.
3. Select the `runetfreedom/russia-v2ray-rules-dat` option.

![Step 1: Geo Asset Configuration](https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/images/v2rayn_geofiles.png)

### 3. Import custom rules
To use my specific profiles (overwriting the defaults if desired):
1. Navigate to **Settings** > **Routing Setting**.
2. Click **Add** to create a new profile (or double-click an existing one to overwrite it).
3. **Remark:** Enter a name for the profile.
4. **Domain Strategy:** Choose **IPOnDemand**.
5. **URL:** Paste the raw link of one of the profiles above.
6. Click **Import rules from subscription url**.
7. Select **Append** if you've created a new profile, or **Replace** if you're editing a default preset.

Alternatively, if pasting from URL won't work for you, you can always visit the page, copy all .json contents, and press **Import from clipboard**, then either **Append** or **Replace** as stated above.\
Same thing goes for updating the rules.

> ### Updating
> When you need to update the rules to the latest version:
> 1. Open your existing routing profile in **Routing Setting**.
> 2. Click **Import rules from subscription url** again.
> 3. When prompted, you **must select Replace** to overwrite old rules with the updated ones.

![Step 2: Rule Import Process](https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/images/v2rayn_routing.png)

### 4. Activate the Routing Profile
1. On the main application window, look for the **Routing** dropdown menu at the bottom.
2. Select the custom profile you just created/updated.
3. Enable **Tun Mode** or **System Proxy** depending on your needs.

![Step 3: Activating the Route](https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/images/v2rayn_modes.png)

## Throne

### 1. Using default presets
1. In **Routing** > **Downloads Profiles** choose whatever preset suits you.
2. In the same **Routing** menu, after the preset is downloaded, select it.
3. In **Settings** > **Tun Settings** enable **Tun Routing**.

### 2. Using custom presets
1. In **Routing** > **Routing Settings** > **Route** click **New**.
2. Set **Default outbound** to **Direct** if you've chosen "blocked_only", or to **Proxy** if other two profiles.
3. In **Advanced** click on **Import JSON** and paste in the chosen .json profile.
5. Select the profile in the **Routing** menu.
6. In **Settings** > **Tun Settings** enable **Tun Routing**.

Enable **Tun Mode** or **System Proxy**, preferably **Tun** if you plan on gaming and using Discord, and activate a profile by right clicking and selecting **Start**, and you're good to go.

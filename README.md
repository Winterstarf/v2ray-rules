# Info
These presets are made with the intention to proxy only those domains and CIDRs that are blocked in Russia, and direct domestic and non-restricted traffic to not hog up my server's bandwidth.\
Even though I initially created this repo to only contain v2ray/xray .json-formatted presets, I also included presets for sing-box.

I should also mention that the presets are made possible using geofiles from the [runetfreedom](https://github.com/runetfreedom/russia-v2ray-rules-dat) repo, which are maintained by the community.

## Client apps
* **xray/v2ray** — [v2rayN](https://github.com/2dust/v2rayN) (Linux, Win, macOS), [v2rayNG](https://github.com/2dust/v2rayNG) (Android), [v2RayTun](https://github.com/DigneZzZ/v2raytun) (Android, iOS, Win (uses sing-box), [Happ](https://www.happ.su/main) (Android, iOS, Linux, Win, macOS), [Streisand](https://apps.apple.com/us/app/streisand/id6450534064) (iOS)
* **sing-box** — [Throne](https://github.com/throneproj/Throne) (Linux, Win, macOS), [NyameBox](https://github.com/qr243vbi/nekobox) (Linux, Win), [NekoBox](https://github.com/starifly/NekoBoxForAndroid) (Android), [husi](https://github.com/xchacha20-poly1305/husi) (Android)

## Presets

There currently exists 3 routing presets:

| Preset | Description
| :--- | :--- 
| **blocked_only** | Proxies only known blocked domains and CIDR ranges
| **except_ru** | Proxies all traffic except for Russian domains and CIDRs
| **all** | Proxies all traffic

Whichever client you choose, they will *in theory* accept .json-fornmatted rules, but it varies by the core it uses, as **v2ray/xray** config format is different from that of **sing-box** etc.\
Note that **v2ray/xray** and **sing-box** rules *might have* differences to some non-critical degree, but I usually try to keep parity between them when updating.

### Raw links for v2ray/xray core presets (v2rayN, v2rayNG)
* **blocked_only**: `https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/rules/blocked_only.json`
* **except_ru**: `https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/rules/except_ru.json`
* **all**: `https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/rules/all.json`

### Raw links for sing-box core presets (Throne)
* **blocked_only**: `https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/rules/blocked_only-singbox.json`
* **except_ru**: `https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/rules/except_ru-singbox.json`
* **all**: `https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/rules/all-singbox.json`

### Base64 encoded presets for v2RayTun
* **blocked_only**: 
```
eyJkb21haW5TdHJhdGVneSI6IklQT25EZW1hbmQiLCJpZCI6IkYwRkRFMUY3LTg5NTctNEQ4Ni1CNUQ1LUUyRTlCNTZCQUZDNyIsImJhbGFuY2VycyI6W10sImRvbWFpbk1hdGNoZXIiOiJoeWJyaWQiLCJuYW1lIjoiUnVsZXNldCIsInJ1bGVzIjpbeyJfX25hbWVfXyI6IkJsb2NrIEFkcyIsImlkIjoiQ0MzMEU3MTQtMTc0NS00Q0M4LTlDNUMtMTMxMTMxMUQ1MUU1IiwidHlwZSI6ImZpZWxkIiwiZG9tYWluIjpbImdlb3NpdGU6Y2F0ZWdvcnktYWRzLWFsbCJdLCJvdXRib3VuZFRhZyI6ImJsb2NrIn0seyJfX25hbWVfXyI6IkRpcmVjdCBwcml2YXRlIGRvbWFpbnMiLCJpZCI6IjMyNjg4RjBDLThBMzktNDlGNS05MjY0LTM3QTgwREYwQjlGQyIsInR5cGUiOiJmaWVsZCIsImRvbWFpbiI6WyJnZW9zaXRlOnByaXZhdGUiXSwib3V0Ym91bmRUYWciOiJkaXJlY3QifSx7Il9fbmFtZV9fIjoiUHJveHkgc29jaWFsIGRvbWFpbnMiLCJpZCI6IkFEM0E5MkYxLUU0OTEtNDZDNi1CRDhCLTY4MjMwNkEzRjM1NSIsInR5cGUiOiJmaWVsZCIsImRvbWFpbiI6WyJnZW9zaXRlOmRpc2NvcmQiLCJnZW9zaXRlOnRlbGVncmFtIiwiZ2Vvc2l0ZTp3aGF0c2FwcCJdLCJvdXRib3VuZFRhZyI6InByb3h5In0seyJfX25hbWVfXyI6IlByb3h5IGJsb2NrZWQgZG9tYWlucyIsImlkIjoiM0E5QURFQjktQzMyQy00QjhDLUIwRjktNDgwMjVCQjFEM0QxIiwidHlwZSI6ImZpZWxkIiwiZG9tYWluIjpbImdlb3NpdGU6cnUtYmxvY2tlZCIsImdlb3NpdGU6Z29vZ2xlLWdlbWluaSIsImdlb3NpdGU6cm9ibG94Il0sIm91dGJvdW5kVGFnIjoicHJveHkifSx7Il9fbmFtZV9fIjoiRGlyZWN0IGJpdHRvcnJlbnQiLCJpZCI6IkRFRkZCQzJGLUFBNDUtNDA4QS1BOERELUJFRUZCRUIzQjMyOCIsInR5cGUiOiJmaWVsZCIsInByb3RvY29sIjpbImJpdHRvcnJlbnQiXSwib3V0Ym91bmRUYWciOiJkaXJlY3QifSx7Il9fbmFtZV9fIjoiRGlyZWN0IHByaXZhdGUgQ0lEUiIsImlkIjoiRUMzMjkxNDUtNjc0OC00OERFLUI3NEEtMzEzN0E0ODBGNDExIiwidHlwZSI6ImZpZWxkIiwiaXAiOlsiZ2VvaXA6cHJpdmF0ZSJdLCJvdXRib3VuZFRhZyI6ImRpcmVjdCJ9LHsiX19uYW1lX18iOiJQcm94eSBzb2NpYWwgQ0lEUiIsImlkIjoiNzk3QjlFREUtREE3Qy00QzI4LUI5NUItM0EzNEY3RkIwMEEyIiwidHlwZSI6ImZpZWxkIiwiaXAiOlsiZ2VvaXA6dGVsZWdyYW0iXSwib3V0Ym91bmRUYWciOiJwcm94eSJ9LHsiX19uYW1lX18iOiJQcm94eSBibG9ja2VkIENJRFIiLCJpZCI6IjIyMTMyOURBLTZFOUItNEVCNS1BRThELUExOTNERTBCMjBGNCIsInR5cGUiOiJmaWVsZCIsImlwIjpbImdlb2lwOnJ1LWJsb2NrZWQtY29tbXVuaXR5IiwiZ2VvaXA6cmUtZmlsdGVyIl0sIm91dGJvdW5kVGFnIjoicHJveHkifSx7Il9fbmFtZV9fIjoiRGlyZWN0IGVsc2UiLCJpZCI6IkVBMjJGMjhFLTQxMTQtNDc5NS04NDc5LUY0MTE1NjM4Rjg3RiIsInR5cGUiOiJmaWVsZCIsInBvcnQiOiIwLTY1NTM1Iiwib3V0Ym91bmRUYWciOiJkaXJlY3QifV19
```
* **except_ru**: 
```
eyJkb21haW5TdHJhdGVneSI6IklQT25EZW1hbmQiLCJpZCI6IjM2NDQxNTA2LTFGN0UtNEY1NS05RTM0LTFGQjJERjJFQkFBNSIsImJhbGFuY2VycyI6W10sImRvbWFpbk1hdGNoZXIiOiJoeWJyaWQiLCJuYW1lIjoiUnVsZXNldCIsInJ1bGVzIjpbeyJfX25hbWVfXyI6IkJsb2NrIEFkcyIsImlkIjoiNzMxMDNDQzYtQzFGMy00MTYzLThBNzMtOEQ3REM3QkZCQjNDIiwidHlwZSI6ImZpZWxkIiwiZG9tYWluIjpbImdlb3NpdGU6Y2F0ZWdvcnktYWRzLWFsbCJdLCJvdXRib3VuZFRhZyI6ImJsb2NrIn0seyJfX25hbWVfXyI6IkRpcmVjdCBwcml2YXRlIGRvbWFpbnMiLCJpZCI6IjJGMTlDRkQzLUVERTAtNDg4MS04MkFBLTcxRTU1NTk2OUQ0QyIsInR5cGUiOiJmaWVsZCIsImRvbWFpbiI6WyJnZW9zaXRlOnByaXZhdGUiXSwib3V0Ym91bmRUYWciOiJkaXJlY3QifSx7Il9fbmFtZV9fIjoiRGlyZWN0IFJVIGRvbWFpbnMiLCJpZCI6IjQ5NjhCNjhBLUYwNEEtNDdEMi04OUYyLUM3QzFCODkyQTE3NSIsInR5cGUiOiJmaWVsZCIsImRvbWFpbiI6WyJnZW9zaXRlOnJ1LWF2YWlsYWJsZS1vbmx5LWluc2lkZSIsImdlb3NpdGU6Y2F0ZWdvcnktcnUiXSwib3V0Ym91bmRUYWciOiJkaXJlY3QifSx7Il9fbmFtZV9fIjoiRGlyZWN0IGJpdHRvcnJlbnQiLCJpZCI6IkJCMzI1RTI0LUYwNkMtNDk0NC1CMDFELTcyMkFFQjFCNTFFRSIsInR5cGUiOiJmaWVsZCIsInByb3RvY29sIjpbImJpdHRvcnJlbnQiXSwib3V0Ym91bmRUYWciOiJkaXJlY3QifSx7Il9fbmFtZV9fIjoiRGlyZWN0IHByaXZhdGUgQ0lEUiIsImlkIjoiMUREQTQxRUUtMEUyQi00MjRGLUE0NzUtNkM5NTI4RkUxRkUyIiwidHlwZSI6ImZpZWxkIiwiaXAiOlsiZ2VvaXA6cHJpdmF0ZSJdLCJvdXRib3VuZFRhZyI6ImRpcmVjdCJ9LHsiX19uYW1lX18iOiJEaXJlY3QgUlUgQ0lEUiIsImlkIjoiRThFQkMxNjAtRkM2My00ODg0LUJCMzQtMEY5Nzg4NDAwQUIyIiwidHlwZSI6ImZpZWxkIiwiaXAiOlsiZ2VvaXA6cnUiXSwib3V0Ym91bmRUYWciOiJkaXJlY3QifSx7Il9fbmFtZV9fIjoiUHJveHkgZWxzZSIsImlkIjoiNzE2QzQ1NzktNUY1Mi00QUZBLUExODAtOTkyODYwNERENkU3IiwidHlwZSI6ImZpZWxkIiwicG9ydCI6IjAtNjU1MzUiLCJvdXRib3VuZFRhZyI6InByb3h5In1dfQ==
```
* **all**:
```
eyJkb21haW5TdHJhdGVneSI6IklQT25EZW1hbmQiLCJpZCI6Ijc0Q0Q0RUI5LTQ0NzUtNEZBMC04MzA1LTI2NTZGMzM3MjkwRiIsImJhbGFuY2VycyI6W10sImRvbWFpbk1hdGNoZXIiOiJoeWJyaWQiLCJuYW1lIjoiUnVsZXNldCIsInJ1bGVzIjpbeyJfX25hbWVfXyI6IkJsb2NrIEFkcyIsImlkIjoiMDJBN0U5RjAtRDg0RC00Nzc5LThGRkEtQjQ4NEFFNEM2RTAwIiwidHlwZSI6ImZpZWxkIiwiZG9tYWluIjpbImdlb3NpdGU6Y2F0ZWdvcnktYWRzLWFsbCJdLCJvdXRib3VuZFRhZyI6ImJsb2NrIn0seyJfX25hbWVfXyI6IkRpcmVjdCBwcml2YXRlIGRvbWFpbnMiLCJpZCI6IjA2MDNGQkJBLUI1RjItNDhCOC1BRTVFLTM3MERFMEM2NDYwQyIsInR5cGUiOiJmaWVsZCIsImRvbWFpbiI6WyJnZW9zaXRlOnByaXZhdGUiXSwib3V0Ym91bmRUYWciOiJkaXJlY3QifSx7Il9fbmFtZV9fIjoiRGlyZWN0IGJpdHRvcnJlbnQiLCJpZCI6IkQwREVERDBBLTU1MzUtNDcwNC04ODBBLTdCMjc2MjE3MDg0OSIsInR5cGUiOiJmaWVsZCIsInByb3RvY29sIjpbImJpdHRvcnJlbnQiXSwib3V0Ym91bmRUYWciOiJkaXJlY3QifSx7Il9fbmFtZV9fIjoiRGlyZWN0IHByaXZhdGUgQ0lEUiIsImlkIjoiMDlCNkU5NEEtNkRENC00NjYxLUE4MUYtNDM5NDM0RUU2Qjc2IiwidHlwZSI6ImZpZWxkIiwiaXAiOlsiZ2VvaXA6cHJpdmF0ZSJdLCJvdXRib3VuZFRhZyI6ImRpcmVjdCJ9LHsiX19uYW1lX18iOiJQcm94eSBlbHNlIiwiaWQiOiJBMEFERTUyOC1CQUYzLTQ4RDYtQjNGRS1EODVGMDkxQTkyQTAiLCJ0eXBlIjoiZmllbGQiLCJwb3J0IjoiMC02NTUzNSIsIm91dGJvdW5kVGFnIjoicHJveHkifV19
```

---
# Guides
This section is completely optional, because it is generally easy to import and use routing presets. However, I did make some basic how-to's just in case someone would need them.

Be wary that most apps already have means of downloading some basic routing presets made either by their authors or by the community, therefore you may or may not need my custom presets from this repo (why would you come here then, anyways?), so in case if you do want to apply custom rules, either mine or your own, continue with the guides below.

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

## v2RayTun

### 1. Configure Geo-Asset source
1. Open the app and go to the **Routing** menu.
2. Tap the **Square with an arrow** icon.
3. Locate **Geo files source** and select `runetfreedom/russia-v2ray-rules-dat` from the dropdown list.
4. Tap the **Cloud icon** to start the download. Wait until the `.dat` files are fully updated.

<img src="https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/images/v2raytun_geofiles.png" width="350">

### 2. Set domain strategy
1. In the **Routing** menu, find the **Domain Strategy** setting and choose **IPOnDemand**.
2. Copy the chosen Base64 code to your clipboard.
3. In v2RayTun, tap the **three dots menu** (top right).
4. Select **Import ruleset from clipboard**.

<img src="https://raw.githubusercontent.com/Winterstarf/v2ray-rules/refs/heads/main/images/v2raytun_routing.png" width="350">

## Trivia

* **Custom service outing:** You can manually route specific domains or services by using the **Services** menu on the main screen. This is useful for forcing specific sites through the proxy regardless of global rules (only in v2RayTun, Streisand, and some others).
* **Custom app routing:** In the **Routing** menu, you can choose exactly which apps on your device use the proxy. 
    * **Routing of selectyed applications:** If you choose this, remember to select your browser and any other apps that need to be proxied.
    * **Bypass Mode:** Useful if you want everything proxied except for local apps (like banking or govt services).

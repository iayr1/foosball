"""Uploads Sling Arena to Google Play with the official Play Developer API.

It sends the release bundle, the store listing text and all images in
fastlane/metadata/android/en-US, as one edit, to the track you choose.

One-time setup
  1. Create the app once by hand in Play Console (the API cannot create apps)
     and upload the first bundle there.
  2. Play Console > Setup > API access: link a Google Cloud project and create a
     service account with "Release manager" rights for this app. Download its JSON key.
  3. pip install google-api-python-client google-auth

Use (from the project root)
  python tool/play_upload.py --key path/to/service-account.json --track internal
  python tool/play_upload.py --key ... --listing-only
Never commit the JSON key.
"""
import argparse
import os
import sys

PACKAGE = "online.athlorun.sling"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
META = os.path.join(ROOT, "fastlane", "metadata", "android", "en-US")
AAB = os.path.join(ROOT, "build", "app", "outputs", "bundle", "release", "app-release.aab")


def read(name):
    with open(os.path.join(META, name), encoding="utf-8") as f:
        return f.read().strip()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--key", required=True, help="service account JSON key file")
    ap.add_argument("--track", default="internal", choices=["internal", "alpha", "beta", "production"])
    ap.add_argument("--status", default="draft", choices=["draft", "completed"], help="draft = review in Console before rollout")
    ap.add_argument("--listing-only", action="store_true", help="update text and images only")
    args = ap.parse_args()

    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build
        from googleapiclient.http import MediaFileUpload
    except ImportError:
        sys.exit("Install the client first: pip install google-api-python-client google-auth")

    creds = service_account.Credentials.from_service_account_file(
        args.key, scopes=["https://www.googleapis.com/auth/androidpublisher"])
    service = build("androidpublisher", "v3", credentials=creds, cache_discovery=False)
    edits = service.edits()
    edit_id = edits.insert(packageName=PACKAGE, body={}).execute()["id"]
    print("Opened edit", edit_id)

    edits.listings().update(
        packageName=PACKAGE, editId=edit_id, language="en-US",
        body={
            "language": "en-US",
            "title": read("title.txt"),
            "shortDescription": read("short_description.txt"),
            "fullDescription": read("full_description.txt"),
        },
    ).execute()
    print("Listing text updated")

    images = os.path.join(META, "images")
    for image_type, files in [
        ("icon", ["icon.png"]),
        ("featureGraphic", ["featureGraphic.png"]),
        ("phoneScreenshots", sorted(os.listdir(os.path.join(images, "phoneScreenshots")))),
    ]:
        edits.images().deleteall(packageName=PACKAGE, editId=edit_id, language="en-US", imageType=image_type).execute()
        for name in files:
            path = os.path.join(images, "phoneScreenshots", name) if image_type == "phoneScreenshots" else os.path.join(images, name)
            edits.images().upload(
                packageName=PACKAGE, editId=edit_id, language="en-US", imageType=image_type,
                media_body=MediaFileUpload(path, mimetype="image/png"),
            ).execute()
        print(f"Uploaded {image_type}: {len(files)} file(s)")

    if not args.listing_only:
        if not os.path.exists(AAB):
            sys.exit("No bundle found. Run: flutter build appbundle --release")
        bundle = edits.bundles().upload(
            packageName=PACKAGE, editId=edit_id,
            media_body=MediaFileUpload(AAB, mimetype="application/octet-stream", resumable=True),
        ).execute()
        code = bundle["versionCode"]
        print("Uploaded bundle, versionCode", code)
        notes_file = os.path.join(META, "changelogs", f"{code}.txt")
        notes = [{"language": "en-US", "text": open(notes_file, encoding="utf-8").read().strip()}] if os.path.exists(notes_file) else []
        edits.tracks().update(
            packageName=PACKAGE, editId=edit_id, track=args.track,
            body={"track": args.track, "releases": [{"versionCodes": [str(code)], "status": args.status, "releaseNotes": notes}]},
        ).execute()
        print(f"Release set on track '{args.track}' as {args.status}")

    edits.commit(packageName=PACKAGE, editId=edit_id).execute()
    print("Committed. Check Play Console for review status.")


if __name__ == "__main__":
    main()

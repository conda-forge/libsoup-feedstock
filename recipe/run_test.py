import sys
# Windows is built without gi support
# https://github.com/conda-forge/libsoup-feedstock/issues/46
if sys.platform == 'win32':
    sys.exit(0)

import gi
import os
from pathlib import PurePath

gi.require_version("Soup", "3.0")
from gi.repository import GObject, Soup, Gio, GLib

# version check
assert Soup.get_major_version() == Soup.MAJOR_VERSION
assert Soup.get_minor_version() == Soup.MINOR_VERSION
# assert Soup.get_micro_version() == Soup.MICRO_VERSION

msg = Soup.Message.new("GET", "https://conda-forge.org")
session = Soup.Session.new()

if os.name == 'nt':
    ca_file = PurePath(os.environ["CONDA_PREFIX"], "Library", "ssl", "cacert.pem")
    try:
        db = Gio.TlsFileDatabase.new(str(ca_file))
    except GLib.Error as e:
        print(f"Could not create TLS database for {str(ca_file)} -> {e.message}")
        sys.exit(1)
    else:
        session.props.tls_database = db
        session.props.ssl_use_system_ca_file = False

session.send_and_read(msg, None) # blocks
if msg.props.status_code < 200 or msg.props.status_code >= 300:
    print(f"Found status code: {msg.props.status_code}")

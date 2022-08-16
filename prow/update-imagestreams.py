#!/usr/bin/env python3
# add-ist
# Copyright(C) 2021 Christoph Görn
#
# This program is free software: you can redistribute it and / or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


"""GitOps tool to add an ImageStreamTag."""

import sys
import logging

from yaml import load_all, dump_all

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

logging.basicConfig(level=logging.INFO)


def reset_latest_tag(imagestream: dict, new_tag: str) -> None:
    """Reset the latest tag of the imagestream to the tag provided."""
    for tag in imagestream["spec"]["tags"]:
        if tag["name"] == "latest":
            logging.info(
                f"resetting latest tag from {tag['from']['name']} to {new_tag}"
            )
            tag["from"]["name"] = new_tag
    return


def add_tag(imagestream: dict, tag_name: str) -> None:
    """Add the tag name to the ImageStream."""
    image_name = imagestream["metadata"]["name"]
    imagestream["spec"]["tags"].append(
        {
            "name": tag_name,
            "from": {
                "kind": "DockerImage",
                "name": f"gcr.io/k8s-prow/{image_name}:{tag_name}",
            },
        }
    )


stream = None
with open("overlays/smaug/imagestreamtags.yaml") as ist:
    stream = load_all(ist.read(), Loader=Loader)

updated_imagestream_tags = []
current_tag = sys.argv[1] if len(sys.argv) > 1 else "v20220812-9414716697"
for data in stream:
    logging.info(f"updating ImageStream '{data['metadata']['name']}'")
    add_tag(data, current_tag)
    reset_latest_tag(data, current_tag)

    updated_imagestream_tags.append(data)

with open("overlays/smaug/imagestreamtags.yaml", "w") as ist:
    ist.write(dump_all(updated_imagestream_tags, Dumper=Dumper, sort_keys=True))

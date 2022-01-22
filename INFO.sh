#!/bin/bash
# Copyright (c) 2000-2020 Synology Inc. All rights reserved.

package="VideoRenamer"

. "/pkgscripts-ng/include/pkg_util.sh"

version="${SPK_PACKAGE_VERSION:-1.0.0}"



maintainer="Sylvain Grosset x @tomgrv"
maintainer_url="https://github.com/tomgrv/videorenamer"
support_url="https://github.com/tomgrv/videorenamer"

os_min_ver="7.0-40000"
arch="noarch"
startable="yes"
silent_install="yes"
silent_uninstall="yes"
silent_upgrade="yes"
dsmuidir="ui"
reloadui="yes"
thirdparty="yes"
support_conf_folder="yes"
support_center="no"
dsmappname="SYNO.SDS.VideoRenamer"
log_whitelist="/var/packages/VideoRenamer/target/etc/log_whitelist"


install_dep_packages="VideoStation"

displayname="Video Renamer - Repackaged for DSM7.0"
description="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_chs="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_cht="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_csy="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_dan="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_enu="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_fre="Video Renammer renomme quotidiennement vos videos (films et series), sous titres, vsmeta et dossiers en accord avec Video Station. Reglez l'heure d'execution souhaité, la façon dont vous voulez renomer vos fichiers et laissez le faire"
description_ger="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_hun="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_ita="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_jpn="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_krn="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_nld="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_nor="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_plk="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_ptb="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_ptg="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_rus="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_spn="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_sve="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"
description_trk="Video Renamer daily renames your videos (movies and tvshows), subtitles, vsmeta and folders according to Video Station. Just set a time for it to run, select the way you want your files renamed and let it role"


[ "$(caller)" != "0 NULL" ] && return 0
pkg_dump_info


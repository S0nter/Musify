/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     Musify is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Musify is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Musify, including how to contribute,
 *     please visit: https://github.com/gokadzev/Musify
 */

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musify/API/musify.dart';
import 'package:musify/extensions/l10n.dart';
import 'package:musify/main.dart';
import 'package:musify/services/router_service.dart';
import 'package:musify/utilities/flutter_toast.dart';
import 'package:musify/widgets/confirmation_dialog.dart';
import 'package:musify/widgets/custom_search_bar.dart';
import 'package:musify/widgets/playlist_bar.dart';
import 'package:musify/widgets/section_title.dart';
import 'package:musify/widgets/spinner.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController _searchBar = TextEditingController();
  final FocusNode _inputNode = FocusNode();

  Future<List> _userPlaylistsFuture = getUserPlaylists();

  // user playlists / playlists / albums
  final List<bool> _visibleSections = [true, false, false];

  Future<void> _refreshUserPlaylists() async {
    setState(() {
      _userPlaylistsFuture = getUserPlaylists();
    });
  }

  @override
  void dispose() {
    _searchBar.dispose();
    _inputNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n!.library),
      ),
      body: Column(
        children: <Widget>[
          CustomSearchBar(
            onSubmitted: (String value) {
              setState(() {});
            },
            controller: _searchBar,
            focusNode: _inputNode,
            labelText: '${context.l10n!.search}...',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(0, context.l10n!.userPlaylists),
                _buildFilterChip(1, context.l10n!.playlists),
                _buildFilterChip(2, context.l10n!.albums),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_visibleSections[0])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SectionTitle(context.l10n!.userPlaylists, primaryColor),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                var id = '';
                                var customPlaylistName = '';
                                var isYouTubeMode = true;
                                String? imageUrl;

                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    final activeButtonBackground =
                                        Theme.of(context)
                                            .colorScheme
                                            .surfaceContainer;
                                    final inactiveButtonBackground =
                                        Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer;
                                    return AlertDialog(
                                      backgroundColor: Theme.of(context)
                                          .dialogBackgroundColor,
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isYouTubeMode = true;
                                                      id = '';
                                                      customPlaylistName = '';
                                                      imageUrl = null;
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: isYouTubeMode
                                                        ? inactiveButtonBackground
                                                        : activeButtonBackground,
                                                  ),
                                                  child: const Icon(
                                                    FluentIcons
                                                        .globe_add_24_filled,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isYouTubeMode = false;
                                                      id = '';
                                                      customPlaylistName = '';
                                                      imageUrl = null;
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: isYouTubeMode
                                                        ? activeButtonBackground
                                                        : inactiveButtonBackground,
                                                  ),
                                                  child: const Icon(
                                                    FluentIcons
                                                        .person_add_24_filled,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 15),
                                            if (isYouTubeMode)
                                              TextField(
                                                decoration: InputDecoration(
                                                  labelText: context.l10n!
                                                      .youtubePlaylistLinkOrId,
                                                ),
                                                onChanged: (value) {
                                                  id = value;
                                                },
                                              )
                                            else ...[
                                              TextField(
                                                decoration: InputDecoration(
                                                  labelText: context
                                                      .l10n!.customPlaylistName,
                                                ),
                                                onChanged: (value) {
                                                  customPlaylistName = value;
                                                },
                                              ),
                                              const SizedBox(height: 7),
                                              TextField(
                                                decoration: InputDecoration(
                                                  labelText: context.l10n!
                                                      .customPlaylistImgUrl,
                                                ),
                                                onChanged: (value) {
                                                  imageUrl = value;
                                                },
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text(
                                            context.l10n!.add.toUpperCase(),
                                          ),
                                          onPressed: () async {
                                            if (isYouTubeMode &&
                                                id.isNotEmpty) {
                                              showToast(
                                                context,
                                                await addUserPlaylist(
                                                  id,
                                                  context,
                                                ),
                                              );
                                            } else if (!isYouTubeMode &&
                                                customPlaylistName.isNotEmpty) {
                                              showToast(
                                                context,
                                                createCustomPlaylist(
                                                  customPlaylistName,
                                                  imageUrl,
                                                  context,
                                                ),
                                              );
                                            } else {
                                              showToast(
                                                context,
                                                '${context.l10n!.provideIdOrNameError}.',
                                              );
                                            }

                                            Navigator.pop(context);

                                            await _refreshUserPlaylists();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                          icon: Icon(
                            FluentIcons.add_24_filled,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  if (_visibleSections[0])
                    Column(
                      children: <Widget>[
                        PlaylistBar(
                          context.l10n!.recentlyPlayed,
                          onPressed: () => NavigationManager.router
                              .go('/playlists/userSongs/recents'),
                          cubeIcon: FluentIcons.history_24_filled,
                        ),
                        PlaylistBar(
                          context.l10n!.likedSongs,
                          onPressed: () => NavigationManager.router
                              .go('/playlists/userSongs/liked'),
                          cubeIcon: FluentIcons.music_note_2_24_regular,
                        ),
                        PlaylistBar(
                          context.l10n!.likedPlaylists,
                          onPressed: () => NavigationManager.router
                              .go('/playlists/userLikedPlaylists'),
                          cubeIcon: FluentIcons.task_list_ltr_24_regular,
                        ),
                        PlaylistBar(
                          context.l10n!.offlineSongs,
                          onPressed: () => NavigationManager.router
                              .go('/playlists/userSongs/offline'),
                          cubeIcon: FluentIcons.cellular_off_24_filled,
                        ),
                      ],
                    ),
                  if (_visibleSections[0])
                    FutureBuilder(
                      future: _userPlaylistsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Spinner();
                        } else if (snapshot.hasError) {
                          logger.log(
                            'Error while fetching user playlists',
                            snapshot.error,
                            snapshot.stackTrace,
                          );
                          return Center(
                            child: Text(context.l10n!.error),
                          );
                        }

                        final _playlists = snapshot.data as List;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _playlists.length,
                          itemBuilder: (BuildContext context, index) {
                            final playlist = _playlists[index];

                            return PlaylistBar(
                              playlist['title'],
                              playlistId: playlist['ytid'],
                              playlistArtwork: playlist['image'],
                              isAlbum: playlist['isAlbum'],
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ConfirmationDialog(
                                      confirmationMessage:
                                          context.l10n!.removePlaylistQuestion,
                                      submitMessage: context.l10n!.remove,
                                      onCancel: () {
                                        Navigator.of(context).pop();
                                      },
                                      onSubmit: () {
                                        Navigator.of(context).pop();

                                        if (playlist['ytid'] == null &&
                                            playlist['isCustom']) {
                                          removeUserCustomPlaylist(playlist);
                                        } else {
                                          removeUserPlaylist(playlist['ytid']);
                                        }

                                        _refreshUserPlaylists();
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  if (_visibleSections[1])
                    SectionTitle(context.l10n!.playlists, primaryColor),
                  if (_visibleSections[1])
                    FutureBuilder(
                      future: getPlaylists(
                        query: _searchBar.text.isEmpty ? null : _searchBar.text,
                        type: 'playlist',
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Spinner();
                        } else if (snapshot.hasError) {
                          logger.log(
                            'Error while fetching playlists',
                            snapshot.error,
                            snapshot.stackTrace,
                          );
                          return Center(
                            child: Text(context.l10n!.error),
                          );
                        }

                        final _playlists = snapshot.data as List;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _playlists.length,
                          itemBuilder: (BuildContext context, index) {
                            final playlist = _playlists[index];

                            return PlaylistBar(
                              playlist['title'],
                              playlistId: playlist['ytid'],
                              playlistArtwork: playlist['image'],
                              isAlbum: playlist['isAlbum'],
                            );
                          },
                        );
                      },
                    ),
                  if (_visibleSections[2])
                    SectionTitle(context.l10n!.albums, primaryColor),
                  if (_visibleSections[2])
                    FutureBuilder(
                      future: getPlaylists(
                        query: _searchBar.text.isEmpty ? null : _searchBar.text,
                        type: 'album',
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Spinner();
                        } else if (snapshot.hasError) {
                          logger.log(
                            'Error while fetching albums',
                            snapshot.error,
                            snapshot.stackTrace,
                          );
                          return Center(
                            child: Text(context.l10n!.error),
                          );
                        }

                        final _playlists = snapshot.data as List;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _playlists.length,
                          itemBuilder: (BuildContext context, index) {
                            final playlist = _playlists[index];

                            return PlaylistBar(
                              playlist['title'],
                              playlistId: playlist['ytid'],
                              playlistArtwork: playlist['image'],
                              isAlbum: playlist['isAlbum'],
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    return FilterChip(
      selected: _visibleSections[index],
      label: Text(label),
      onSelected: (isSelected) {
        setState(() {
          _visibleSections[index] = isSelected;
        });
      },
    );
  }
}
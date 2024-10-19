<template>
  <v-container fluid>
    <template v-if="objectInfo">
      <v-row
        v-if="objectInfo.tombstone"
        justify="center"
      >
        <v-col cols="6">
          <v-row justify="center" class="mt-8">
            <v-alert type="info" color="primary">
              <div>
                {{
                  $t("This object has been deleted.")
                }}
              </div>
            </v-alert>
          </v-row>
          <v-row justify="center" class="mt-5">{{ objectInfo.tombstone }}</v-row>
          <template v-if="objectInfo.relationships">
            <v-row
              v-if="objectInfo.relationships.ispartof && objectInfo.relationships.ispartof.length > 0"
              class="my-6"
            >
              <v-col class="pt-0">
                <v-card tile>
                  <v-card-title
                    class="ph-box title font-weight-light grey white--text"
                    >{{ $t("This object is in collection") }}</v-card-title
                  >
                  <v-card-text class="mt-4">
                    <div
                      v-for="(rel, i) in objectInfo.relationships.ispartof" :key="'ispartof' + i"
                    >
                      <v-row v-if="rel" align="center">
                        <v-col cols="12" md="5" class="preview-maxwidth">
                          <p-img
                            :src="instanceconfig.api +
                              '/object/' +
                              rel.pid +
                              '/thumbnail'
                            "
                            class="elevation-1 my-4"
                          ></p-img>
                        </v-col>
                        <v-col cols="12" md="7">
                          <nuxt-link
                            v-if="rel['dc_title']"
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.dc_title[0] }}</nuxt-link
                          >
                          <nuxt-link
                            v-else
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.pid }}</nuxt-link
                          >
                        </v-col>
                      </v-row>
                      <v-divider
                        :key="'ispartofd' + i"
                        v-if="
                          i + 1 < objectInfo.relationships.ispartof.length
                        "
                      ></v-divider>
                    </div>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>

            <v-row
              v-if="objectInfo.relationships.isbacksideof && objectInfo.relationships.isbacksideof.length > 0"
              class="my-6"
            >
              <v-col class="pt-0">
                <v-card tile>
                  <v-card-title
                    class="ph-box title font-weight-light grey white--text"
                    >{{ $t("This object is a back side of") }}</v-card-title
                  >
                  <v-card-text class="mt-4">
                    <div
                      v-for="(rel, i) in objectInfo.relationships
                        .isbacksideof" :key="'isbacksideof' + i"
                    >
                      <v-row align="center">
                        <v-col cols="12" md="5" class="preview-maxwidth">
                          <p-img
                            :src="instanceconfig.api +
                              '/object/' +
                              rel.pid +
                              '/thumbnail'
                            "
                            class="elevation-1 my-4"
                          ></p-img>
                        </v-col>
                        <v-col cols="12" md="7">
                          <nuxt-link
                            v-if="rel['dc_title']"
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.dc_title[0] }}</nuxt-link
                          >
                          <nuxt-link
                            v-else
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.pid }}</nuxt-link
                          >
                        </v-col>
                      </v-row>
                      <v-divider
                        :key="'isbacksideofd' + i"
                        v-if="
                          i + 1 < objectInfo.relationships.isbacksideof.length
                        "
                      ></v-divider>
                    </div>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>

            <v-row
              v-if="objectInfo.relationships.hasbackside && objectInfo.relationships.hasbackside.length > 0"
              class="my-6"
            >
              <v-col class="pt-0">
                <v-card tile>
                  <v-card-title
                    class="ph-box title font-weight-light grey white--text"
                    >{{ $t("This object has a back side") }}</v-card-title
                  >
                  <v-card-text class="mt-4">
                    <div
                      v-for="(rel, i) in objectInfo.relationships.hasbackside" :key="'hasbackside' + i"
                    >
                      <v-row align="center">
                        <v-col cols="12" md="5" class="preview-maxwidth">
                          <p-img
                            :src="instanceconfig.api +
                              '/object/' +
                              rel.pid +
                              '/thumbnail'
                            "
                            class="elevation-1 my-4"
                          ></p-img>
                        </v-col>
                        <v-col cols="12" md="7">
                          <nuxt-link
                            v-if="rel['dc_title']"
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.dc_title[0] }}</nuxt-link
                          >
                          <nuxt-link
                            v-else
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.pid }}</nuxt-link
                          >
                        </v-col>
                      </v-row>
                      <v-divider
                        :key="'hasbacksided' + i"
                        v-if="
                          i + 1 < objectInfo.relationships.hasbackside.length
                        "
                      ></v-divider>
                    </div>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>

            <v-row
              v-if="objectInfo.relationships.isthumbnailfor && objectInfo.relationships.isthumbnailfor.length > 0"
              class="my-6"
            >
              <v-col class="pt-0">
                <v-card tile>
                  <v-card-title
                    class="ph-box title font-weight-light grey white--text"
                    >{{ $t("This object is thumbnail for") }}</v-card-title
                  >
                  <v-card-text class="mt-4">
                    <div
                      v-for="(rel, i) in objectInfo.relationships
                        .isthumbnailfor" :key="'isthumbnailfor' + i"
                    >
                      <v-row align="center">
                        <v-col cols="12" md="5" class="preview-maxwidth">
                          <p-img
                            :src="instanceconfig.api +
                              '/object/' +
                              rel.pid +
                              '/thumbnail'
                            "
                            class="elevation-1 my-4"
                          ></p-img>
                        </v-col>
                        <v-col cols="12" md="7">
                          <nuxt-link
                            v-if="rel['dc_title']"
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.dc_title[0] }}</nuxt-link
                          >
                          <nuxt-link
                            v-else
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.pid }}</nuxt-link
                          >
                        </v-col>
                      </v-row>
                      <v-divider
                        :key="'isthumbnailford' + i"
                        v-if="
                          i + 1 <
                          objectInfo.relationships.isthumbnailfor.length
                        "
                      ></v-divider>
                    </div>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>

            <v-row
              v-if="objectInfo.relationships.hasthumbnail && objectInfo.relationships.hasthumbnail.length > 0"
              class="my-6"
            >
              <v-col class="pt-0">
                <v-card tile>
                  <v-card-title
                    class="ph-box title font-weight-light grey white--text"
                    >{{ $t("This object has thumbnail") }}</v-card-title
                  >
                  <v-card-text class="mt-4">
                    <div
                      v-for="(rel, i) in objectInfo.relationships
                        .hasthumbnail" :key="'hasthumbnail' + i"
                    >
                      <v-row align="center">
                        <v-col cols="12" md="5" class="preview-maxwidth">
                          <p-img
                            :src="instanceconfig.api +
                              '/object/' +
                              rel.pid +
                              '/thumbnail'
                            "
                            class="elevation-1 my-4"
                          ></p-img>
                        </v-col>
                        <v-col cols="12" md="7">
                          <nuxt-link
                            v-if="rel['dc_title']"
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.dc_title[0] }}</nuxt-link
                          >
                          <nuxt-link
                            v-else
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.pid }}</nuxt-link
                          >
                        </v-col>
                      </v-row>
                      <v-divider
                        :key="'hasthumbnaild' + i"
                        v-if="
                          i + 1 < objectInfo.relationships.hasthumbnail.length
                        "
                      ></v-divider>
                    </div>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>

            <v-row
              v-if="objectInfo.relationships.references && objectInfo.relationships.references.length > 0"
              class="my-6"
            >
              <v-col class="pt-0">
                <v-card tile>
                  <v-card-title
                    class="ph-box title font-weight-light grey white--text"
                    >{{ $t("This object references") }}</v-card-title
                  >
                  <v-card-text class="mt-4">
                    <div
                      v-for="(rel, i) in objectInfo.relationships.references" :key="'references' + i"
                    >
                      <v-row align="center">
                        <v-col cols="12" md="5" class="preview-maxwidth">
                          <p-img
                            :src="instanceconfig.api +
                              '/object/' +
                              rel.pid +
                              '/thumbnail'
                            "
                            class="elevation-1 my-4"
                          ></p-img>
                        </v-col>
                        <v-col cols="12" md="7">
                          <nuxt-link
                            v-if="rel['dc_title']"
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.dc_title[0] }}</nuxt-link
                          >
                          <nuxt-link
                            v-else
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.pid }}</nuxt-link
                          >
                        </v-col>
                      </v-row>
                      <v-divider
                        :key="'referencesd' + i"
                        v-if="
                          i + 1 < objectInfo.relationships.references.length
                        "
                      ></v-divider>
                    </div>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>

            <v-row
              v-if="objectInfo.relationships.isreferencedby && objectInfo.relationships.isreferencedby.length > 0"
              class="my-6"
            >
              <v-col class="pt-0">
                <v-card tile>
                  <v-card-title
                    class="ph-box title font-weight-light grey white--text"
                    >{{ $t("This object is referenced by") }}</v-card-title
                  >
                  <v-card-text class="mt-4">
                    <div
                      v-for="(rel, i) in objectInfo.relationships
                        .isreferencedby" :key="'isreferencedby' + i"
                    >
                      <v-row align="center">
                        <v-col cols="12" md="5" class="preview-maxwidth">
                          <p-img
                            :src="instanceconfig.api +
                              '/object/' +
                              rel.pid +
                              '/thumbnail'
                            "
                            class="elevation-1 my-4"
                          ></p-img>
                        </v-col>
                        <v-col cols="12" md="7">
                          <nuxt-link
                            v-if="rel['dc_title']"
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.dc_title[0] }}</nuxt-link
                          >
                          <nuxt-link
                            v-else
                            :to="localePath(`/detail/${rel.pid}`)"
                            >{{ rel.pid }}</nuxt-link
                          >
                        </v-col>
                      </v-row>
                      <v-divider
                        :key="'isreferencedbyd' + i"
                        v-if="
                          i + 1 <
                          objectInfo.relationships.isreferencedby.length
                        "
                      ></v-divider>
                    </div>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>
          </template>
        </v-col>
      </v-row>
      <v-row
        v-else-if="objectInfo.ismemberof && objectInfo.ismemberof.length > 0"
        justify="center"
      >
        <template v-if="objectInfo.ismemberof.length === 1">
          <v-col cols="6">
            <v-row justify="center" class="mt-5">{{
              $t("MEMBER_OF_CONTAINER", {
                containerpid: objectInfo.ismemberof[0],
              })
            }}</v-row>
            <v-row justify="center" class="mt-4"
              ><v-btn
                large
                raised
                color="primary"
                :to="
                  localePath({ path: `/detail/${objectInfo.ismemberof[0]}` })
                "
                >{{ $t("Go to container") }}</v-btn
              ></v-row
            >
          </v-col>
        </template>
        <template v-else>
          <v-col cols="6">
            <v-row justify="center" class="mt-5">{{
              $t(
                "This object is a member of multiple containers. Please choose a container to view:"
              )
            }}</v-row>
            <v-row justify="center" class="mt-4"
              ><v-btn
                v-for="(contpid, i) in objectInfo.ismemberof"
                :key="'contbtn' + i"
                large
                raised
                color="primary"
                :to="localePath({ path: `/detail/${contpid}` })"
                >{{ $t("Go to container") }}&nbsp;{{ contpid }}</v-btn
              ></v-row
            >
          </v-col>
        </template>
      </v-row>
      <v-row v-else>
        <v-col cols="12" md="8" class="mt-8">
          <v-row v-if="objectInfo.cmodel === 'Page'" justify="center">
            <v-col cols="6">
              <v-row justify="center" class="mt-5">{{
                $t("PAGE_OF_BOOK", { bookpid: objectInfo.bookpid })
              }}</v-row>
              <v-row justify="center" class="mt-4"
                ><v-btn
                  large
                  raised
                  color="primary"
                  :to="localePath({ path: `/detail/${objectInfo.bookpid}` })"
                  >{{ $t("Go to book") }}</v-btn
                ></v-row
              >
            </v-col>
          </v-row>
          <v-row v-if="hasLaterVersion" justify="center">
            <v-alert type="info" color="primary">
              <div>
                {{
                  $t("There is a more recent version of this object available")
                }}
              </div>
            </v-alert>
          </v-row>
          <v-row justify="center" v-if="showPreview">
            <template v-if="(objectInfo.cmodel === 'Book') && (objectInfo.datastreams.includes('UWMETADATA'))">
              <v-btn
                large
                raised
                color="primary"
                :href="
                  instanceconfig.fedora +
                  '/objects/' +
                  objectInfo.pid +
                  '/methods/bdef:Book/view'
                "
                target="_blank"
                >{{ $t("Open in Bookviewer") }}</v-btn
              >
            </template>
          <template v-else-if="(objectInfo.cmodel === 'Book') && (objectInfo.datastreams.includes('IIIF-MANIFEST'))">
              <v-btn
                large
                raised
                color="primary"
                :href="
                  instanceconfig.api +
                    '/object/' +
                    objectInfo.pid +
                    '/preview'
                "
                target="_blank"
                >{{ $t("Open in Bookviewer") }}</v-btn
              >
            </template>
            <template v-else>
              <v-col cols="12">
                <div class="iframe-container" v-if="objectInfo.cmodel === 'Video'">
                  <iframe
                    :src="
                      instanceconfig.api +
                      '/object/' +
                      objectInfo.pid +
                      '/preview'
                    "
                    width="100%"
                    frameborder="0"
                    scrolling="no"
                    allowfullscreen="yes"
                    class="responsive-iframe"
                    >Content</iframe>
                </div>
                <iframe
                v-else
                  :src="
                    instanceconfig.api +
                    '/object/' +
                    objectInfo.pid +
                    '/preview'
                  "
                  :style="
                    objectInfo.cmodel === 'Audio'
                      ? 'height: 220px; width: 100%; border: 0px;'
                      : objectInfo.cmodel === 'Container' ? 'height: 300px; width: 100%; border: 0px;' : 'height: 500px; width: 100%; border: 0px;'
                  "
                  scrolling="no"
                  frameborder="0"
                  >Content</iframe
                >
                <v-btn
                raised
                color="primary"
                  class="mt-2 float-right"
                  :href="
                    instanceconfig.api +
                    '/object/' +
                    objectInfo.pid +
                    '/preview'
                  "
                  target="_blank"
                  >{{ $t("Open in new window") }}</v-btn
                >
              </v-col>
            </template>
          </v-row>

          <v-divider class="mt-12 mb-10" v-if="showPreview"></v-divider>
          <v-row justify="center" v-if="objectInfo.dshash['JSON-LD']">
            <p-d-jsonld
              :jsonld="objectInfo.metadata['JSON-LD']"
              :pid="objectInfo.pid"
              :bold-label-fields="['dce:title', 'role', 'edm:rights']"
              :predicatesToHide="['ebucore:filename', 'ebucore:hasMimeType']"
            ></p-d-jsonld>
          </v-row>

          <v-row v-else-if="objectInfo.dshash['UWMETADATA']">
            <p-d-uwm-rec
              :children="objectInfo.metadata['uwmetadata']"
              :cmodel="objectInfo.cmodel"
            ></p-d-uwm-rec>
          </v-row>

          <v-row v-else-if="objectInfo.dshash['MODS']">
            <p-d-mods-rec
              :children="objectInfo.metadata['mods']"
            ></p-d-mods-rec>
          </v-row>

          <template v-if="(objectInfo.cmodel === 'Container') && !objectInfo.datastreams.includes('CONTAINERINFO')">
            <v-toolbar class="my-10 grey white--text" elevation="1">
              <v-toolbar-title>
                {{ $t("Members") }} ({{ objectInfo.members.length }})
              </v-toolbar-title>
              <v-spacer></v-spacer>
              <v-pagination
                v-if="objectInfo.members.length > membersPageSize"
                v-model="membersPage"
                :length="Math.ceil(objectInfo.members.length/membersPageSize)"
              ></v-pagination>
            </v-toolbar>
            <v-row v-if="objectMembers">
              <v-card
                class="mb-3 pt-4"
                width="100%"
                v-for="member in objectMembersPage"
                :key="'member_' + member.pid"
              >
                <iframe
                  :src="
                    instanceconfig.api + '/object/' + member.pid + '/preview'
                  "
                  :style="
                    member.cmodel === 'Audio'
                      ? 'height: 60px; width: 100%; border: 0px;'
                      : 'height: 500px; width: 100%; border: 0px;'
                  "
                  scrolling="no"
                  frameborder="0"
                  >Content</iframe
                >
                <v-card-text class="ma-2">
                  <p-d-jsonld
                    :jsonld="member.metadata['JSON-LD']"
                    :pid="member.pid"
                    :bold-label-fields="['dce:title', 'role', 'edm:rights']"
                    :predicatesToHide="['ebucore:filename', 'ebucore:hasMimeType']"
                  ></p-d-jsonld>
                </v-card-text>
                <v-divider light v-if="objectInfo.readrights"></v-divider>
                <v-card-actions class="pa-3" v-if="objectInfo.readrights">
                  <v-spacer></v-spacer>
                  <v-btn
                    class="ml-2"
                    raised
                    :href="
                      instanceconfig.api + '/object/' + member.pid + '/download'
                    "
                    color="primary"
                    >{{ $t("Download") }}</v-btn
                  >
                  <v-menu offset-y v-if="objectInfo.writerights === 1">
                    <template v-slot:activator="{ on }">
                      <v-btn class="ml-2" raised color="primary" dark v-on="on"
                        >{{ $t("Edit")
                        }}<v-icon right dark>arrow_drop_down</v-icon></v-btn
                      >
                    </template>
                    <v-list>
                      <v-list-item
                        :to="localePath(`/metadata/${member.pid}/edit`)"
                      >
                        <v-list-item-title>{{
                          $t("Edit metadata")
                        }}</v-list-item-title>
                      </v-list-item>
                      <v-list-item :to="localePath(`/rights/${member.pid}`)">
                        <v-list-item-title>{{
                          $t("Access rights")
                        }}</v-list-item-title>
                      </v-list-item>
                      <v-list-item
                        :to="localePath(`/relationships/${member.pid}`)"
                      >
                        <v-list-item-title>{{
                          $t("Relationships")
                        }}</v-list-item-title>
                      </v-list-item>
                      <v-list-item>
                      </v-list-item>
                      <v-list-item v-if="(instanceconfig.showdeletebutton === 1) || (instanceconfig.showdeletebutton === true)" :to="localePath(`/delete/${member.pid}`)">
                        <v-list-item-title>{{
                          $t("Delete")
                        }}</v-list-item-title>
                      </v-list-item>
                    </v-list>
                  </v-menu>
                </v-card-actions>
              </v-card>
            </v-row>
          </template>
          <template v-if="objectInfo.readrights && (objectInfo.cmodel === 'Container') && objectInfo.datastreams.includes('CONTAINERINFO')">
            <v-toolbar class="my-10 grey white--text" elevation="1">
              <v-toolbar-title>
                {{ $t("Members") }} ({{ objectInfo.legacy_container_members.length }})
              </v-toolbar-title>
            </v-toolbar>
            <div v-for="(legacyCMember, i) in objectInfo.legacy_container_members">
            <v-row class="ml-4 pa-2" :key="'legacyCMember' + i">
              <v-col cols="10" class="pt-5">
                {{legacyCMember.filename}}
              </v-col>
              <v-col cols="2">
                <v-btn
                  v-if="objectInfo.readrights"
                  :href="
                    instanceconfig.api +
                    '/object/' +
                    objectInfo.pid +
                    '/comp/' +
                    legacyCMember.ds
                  "
                  color="primary"
                  >{{ $t("Download") }}</v-btn
                >
              </v-col>
            </v-row>
            <v-divider></v-divider>
          </div>
          </template>
          <template v-if="objectInfo.cmodel === 'Collection' && collMembers.length">
            <v-toolbar class="my-10 grey white--text" elevation="1">
              <v-toolbar-title>
                {{ $t("Members") }} ({{ $store.state.collectionMembersTotal /* leave it like this, computed property wasn't working on first access */ }})
              </v-toolbar-title>
              <v-switch @click="refreshCollectionMembers()" class="mx-2" dark hide-details :label="$t('Only latest versions')" v-model="collOnlyLatestVersions"></v-switch>
              <v-spacer></v-spacer>
              <v-pagination
                v-if="$store.state.collectionMembersTotal > collMembersPagesize"
                v-bind:length="collMembersTotalPages"
                total-visible="10"
                v-model="collMembersPage"
              ></v-pagination>
            </v-toolbar>
            <div v-for="(collMember, i) in collMembers" :key="'collMember' + i">
              <v-row class="my-4">
                <v-col cols="1" >
                  <div class="preview-maxwidth">
                    <p-img
                      :src="
                        instanceconfig.api + '/object/' + collMember.pid + '/thumbnail'
                      "
                      class="elevation-1 mt-2"
                    >
                      <template v-slot:placeholder>
                        <div
                          class="fill-height ma-0"
                          align="center"
                          justify="center"
                        >
                          <v-progress-circular
                            indeterminate
                            color="grey lighten-5"
                          ></v-progress-circular>
                        </div>
                      </template>
                    </p-img>
                  </div>
                </v-col>
                <v-col cols="10">
                  <v-row no-gutters class="mb-4">
                    <v-col cols="10">
                      <h3
                        class="title font-weight-light primary--text"
                        @click.stop
                        v-if="collMember.dc_title"
                      >
                        <router-link
                          :to="{ path: `${collMember.pid}`, params: { pid: collMember.pid } }"
                          >{{ collMember.dc_title[0] }}</router-link
                        >
                      </h3>
                      <p class="grey--text">{{ collMember.pid }}</p>
                    </v-col>
                    <v-spacer></v-spacer>
                    <v-col cols="1" class="text-right"
                      ><span v-if="collMember.created" class="grey--text">{{
                        collMember.created | date
                      }}</span></v-col
                    >
                  </v-row>
                </v-col>
                <v-col cols="1" v-if="objectInfo.writerights === 1" justify="center">
                  <v-btn icon class="mt-4" @click="collMemberToRemove = collMember.pid; confirmColMemDeleteDlg = true"><v-icon color="red lighten-1">mdi-delete</v-icon></v-btn>
                </v-col>
              </v-row>
              <v-divider></v-divider>
            </div>
            <v-dialog v-model="confirmColMemDeleteDlg" width="500" >
              <v-card>
                <v-card-title class="title font-weight-light grey lighten-2" primary-title >{{ $t('Remove') }}</v-card-title>
                <v-card-text class="my-4">{{ $t('REMOVE_COLLECTION_MEMBER', { oldpid: collMemberToRemove, collection: objectInfo.pid })}}</v-card-text>
                <v-divider></v-divider>
                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn color="red" class="white--text" :loading="$store.state.loading" :disabled="$store.state.loading" @click="removeFromCollection()">{{ $t('Remove') }}</v-btn>
                  <v-btn :disabled="$store.state.loading" @click="collMemberToRemove = null; confirmColMemDeleteDlg = false">{{ $t('Cancel') }}</v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </template>
        </v-col>

        <v-col cols="12" md="4" class="mt-4">
          <v-row justify="end">
            <v-col cols="12" md="9">
              <v-row
                class="mb-6"
              >
                <v-col class="pt-0">
                  <v-card tile>
                    <v-card-title
                      class="ph-box title font-weight-light grey white--text"
                      >{{ $t('Citable links') }}</v-card-title
                    >
                    <v-card-text class="mt-4">
                      <v-row no-gutters class="pt-2" justify="start">
                       <v-col cols="12" class="pt-0">
                          <p
                            class="text-right"
                            v-for="(id, i) in identifiers.persistent"
                            :key="'id' + i"
                          >
                            <v-dialog
                              @input="loadCitationStyles()"
                              v-if="id.label === 'DOI'"
                              class="pb-4"
                              v-model="doiCiteDialog"
                              width="800px"
                            >
                              <template v-slot:activator="{ on }">
                                <v-chip
                                  v-on="on"
                                  x-small
                                  class="mr-2 font-weight-regular"
                                  color="primary"
                                  >{{ $t("Cite") }}</v-chip
                                >
                              </template>
                              <v-card>
                                <v-card-title
                                  dark
                                  class="title font-weight-light grey white--text"
                                  >{{ $t("Cite") }}</v-card-title
                                >
                                <v-card-text>
                                  <v-container>
                                    <v-row align="center" justify="center">
                                      <v-btn
                                        color="primary"
                                        class="mx-3"
                                        @click="getBibTex()"
                                        >{{ $t("Get BibTex") }}</v-btn
                                      >
                                      <span>{{ $t("or") }}</span>
                                      <v-btn
                                        color="primary"
                                        class="mx-3"
                                        @click="getCitation()"
                                        >{{ $t("Get citation") }}</v-btn
                                      >
                                      <v-autocomplete
                                        :loading="citationStylesLoading"
                                        v-model="citationStyle"
                                        :items="citationStyles"
                                        :label="$t('Style')"
                                      ></v-autocomplete>
                                    </v-row>
                                    <v-row align="center" justify="center">
                                      <v-textarea
                                        hide-details
                                        height="300px"
                                        readonly
                                        filled
                                        v-model="citeResult"
                                      ></v-textarea>
                                    </v-row>
                                  </v-container>
                                </v-card-text>
                                <v-divider></v-divider>
                                <v-card-actions>
                                  <v-spacer></v-spacer>
                                  <v-btn
                                    dark
                                    color="grey"
                                    :loading="doiCiteLoading"
                                    @click="doiCiteDialog = false"
                                    >{{ $t("Close") }}</v-btn
                                  >
                                </v-card-actions>
                              </v-card>
                            </v-dialog>
                            <span v-if="id.label" class="caption text--secondary">
                              {{ $t(id.label) }}
                            </span>
                            <br />
                            <span :class="id.label == 'Persistent identifier' ? 'font-weight-medium primary--text' : ''">
                              <a :href="id.value">{{ id.value }}</a>
                            </span>
                          </p>
                        </v-col>
                      </v-row>
                      <v-row no-gutters justify="end" v-if="(objectInfo.writerights === 1) && !doi && instanceconfig.requestdoiemail && (instanceconfig.requestdoiemail !== '')">
                        <v-dialog
                          class="pb-4"
                          v-model="doiRequestDialog"
                          width="800px"
                        >
                          <template v-slot:activator="{ on }">
                            <v-btn v-on="on" color="primary" @click="doiRequestDialog = true" :loading="doiRequestLoading">{{  $t('Request DOI') }}</v-btn>
                          </template>
                          <v-card>
                            <v-card-title
                              dark
                              class="title font-weight-light grey white--text"
                              >{{ $t("Request DOI") }}</v-card-title
                            >
                            <v-card-text>
                              <v-container>
                                <v-row class="mt-4">
                                  <v-col cols="12">
                                  {{ $t('Do you want to request a DOI for this object?') }}
                                  </v-col>
                                </v-row>
                                <v-row align="center" justify="center">
                                  <v-col cols="12">
                                    <strong>{{ $t('Note') }}</strong>: {{ $t('After the request, please wait for the DOI support to contact you via email.') }}
                                  </v-col>
                                </v-row>
                              </v-container>
                            </v-card-text>
                            <v-divider></v-divider>
                            <v-card-actions>
                              <v-btn
                                dark
                                color="grey"
                                :loading="doiRequestLoading"
                                @click="doiRequestDialog = false"
                                >{{ $t("Cancel") }}</v-btn
                              >
                              <v-spacer></v-spacer>
                              <v-btn
                                color="primary"
                                :loading="doiRequestLoading"
                                @click="requestDOI()"
                                >{{ $t("Request DOI") }}</v-btn
                              >
                            </v-card-actions>
                          </v-card>
                        </v-dialog>
                        
                      </v-row>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>
            </v-col>
          </v-row>

          <v-row justify="end" v-if="identifiers.other.length > 0">
            <v-col cols="12" md="9">
              <v-row
                class="mb-6"
              >
                <v-col class="pt-0">
                  <v-card tile>
                    <v-card-title
                      class="ph-box title font-weight-light grey white--text"
                      >{{ $t('Other links') }}</v-card-title
                    >
                    <v-card-text class="mt-4">
                      <v-row no-gutters class="pt-2" justify="start">
                       <v-col cols="12" class="pt-0">
                          <p
                            class="text-right"
                            v-for="(id, i) in identifiers.other"
                            :key="'id' + i"
                          >
                            <span v-if="id.label" class="caption text--secondary">
                              {{ $t(id.label) }}
                            </span>
                            <br />
                            <a v-if="id.value.startsWith('http')" :href="id.value">{{ id.value }}</a>
                            <span v-else>{{ id.value }}</span>
                          </p>
                        </v-col>
                      </v-row>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>
            </v-col>
          </v-row>

          <v-row justify="end" class="mb-8" no-gutters v-if="objectInfo.isrestricted"><v-chip label dark color="red lighten-1 font-weight-regular"><v-icon small left>mdi-lock</v-icon>{{ $t('Restricted access') }}</v-chip></v-row>
          <v-row justify="end">
            <v-col cols="12" md="9">
              <v-row
                class="mb-6"
                v-if="
                  (downloadable && objectInfo.readrights) ||
                  objectInfo.cmodel === 'Collection' ||
                  objectInfo.cmodel === 'Resource'
                "
              >
                <v-col class="pt-0">
                  <v-card tile>
                    <v-card-title
                      class="ph-box title font-weight-light grey white--text"
                      >{{ $t("Content") }}</v-card-title
                    >
                    <v-card-text class="mt-4">
                      <v-row no-gutters class="pt-2" justify="start">
                        <v-btn
                          class="mr-2 mb-2"
                          v-if="downloadable && objectInfo.readrights"
                          :href="
                            instanceconfig.api +
                            '/object/' +
                            objectInfo.pid +
                            '/download'
                          "
                          color="primary"
                          >{{ $t("Download") }}</v-btn
                        >
                        <v-btn
                          v-if="objectInfo.cmodel === 'Collection'"
                          :to="
                            localePath({
                              path: '/search',
                              query: { collection: objectInfo.pid, reset: 1 },
                            })
                          "
                          color="primary"
                          >{{ $t("Show members") }} ({{
                            objectInfo.haspartsize
                          }})</v-btn
                        >
                        <v-btn
                          v-if="objectInfo.cmodel === 'Resource'"
                          :href="
                            instanceconfig.api +
                            '/object/' +
                            objectInfo.pid +
                            '/resourcelink/redirect'
                          "
                          color="primary"
                          >{{ $t("Open link") }}</v-btn
                        >
                      </v-row>
                      <v-divider
                        class="mt-4 mb-4"
                        v-if="
                          (downloadable &&
                            objectInfo.readrights &&
                            objectInfo.cmodel === 'Picture') ||
                          (downloadable &&
                            objectInfo.readrights &&
                            objectInfo.dshash['WEBVERSION'])
                        "
                      ></v-divider>
                      <template
                        v-if="
                          downloadable &&
                          objectInfo.readrights &&
                          objectInfo.cmodel === 'Picture'
                        "
                      >
                        <v-row no-gutters class="pt-2">
                          <a
                            target="_blank"
                            :href="
                              instanceconfig.api +
                              '/imageserver/?IIIF=' +
                              objectInfo.pid +
                              '.tif/full/pct:50/0/default.jpg'
                            "
                            >{{ $t("View scaled to 50%") }}</a
                          >
                        </v-row>
                        <v-row no-gutters class="pt-2">
                          <a
                            target="_blank"
                            :href="
                              instanceconfig.api +
                              '/imageserver/?IIIF=' +
                              objectInfo.pid +
                              '.tif/full/pct:25/0/default.jpg'
                            "
                            >{{ $t("View scaled to 25%") }}</a
                          >
                        </v-row>
                      </template>
                      <v-row
                        no-gutters
                        class="pt-2"
                        v-if="
                          downloadable &&
                          objectInfo.readrights &&
                          objectInfo.dshash['WEBVERSION']
                        "
                      >
                        <a
                          :href="
                            instanceconfig.api +
                            '/object/' +
                            objectInfo.pid +
                            '/download?trywebversion=1'
                          "
                          >{{ $t("Download web-optimized version") }}</a
                        >
                      </v-row>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>

              <v-row class="mb-6" v-if="objectInfo.isinadminset">
                <v-col class="pt-0">
                  <v-card tile>
                    <v-card-title
                      class="ph-box title font-weight-light grey white--text"
                      >{{ $t("Managed by") }}</v-card-title
                    >
                    <v-card-text class="mt-4">
                      <v-row
                        v-for="(adminset, i) in objectInfo.isinadminset"
                        no-gutters
                        class="pt-2"
                        :key="'adminset' + i"
                      >
                        <a
                          class="font-weight-regular"
                          v-if="adminset === 'phaidra:ir.univie.ac.at'"
                          :href="uscholarlink"
                          target="_blank"
                          >u:scholar</a
                        >
                        <a
                          v-else-if="adminset === 'phaidra:utheses.univie.ac.at'"
                          :href="utheseslink"
                          target="_blank"
                          >u:theses</a
                        >
                        <span v-else>{{ adminset }}</span>
                      </v-row>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>

              <v-row class="mb-6">
                <v-col class="pt-0">
                  <v-card tile>
                    <v-card-title
                      class="ph-box title font-weight-light grey white--text"
                      >{{ $t("Details") }}</v-card-title
                    >
                    <v-card-text class="mt-4">
                      <v-row no-gutters class="pt-2">
                        <v-col
                          class="caption grey--text text--darken-2"
                          cols="3"
                          >{{ $t("Uploader") }}</v-col
                        >
                        <v-col
                          cols="8"
                          offset="1"
                          v-if="objectInfo.owner.firstname"
                        >
                          <a :href="'mailto:' + ownerEmail"
                            >{{ objectInfo.owner.firstname }}
                            {{ objectInfo.owner.lastname }}</a
                          >
                        </v-col>
                        <v-col v-else-if="objectInfo.owner.displayname" cols="8" offset="1">
                          <v-row>
                              <v-col>
                                <a :href="'mailto:' + ownerEmail"
                                  >{{ objectInfo.owner.displayname }}</a
                                >
                              </v-col>
                          </v-row>
                        </v-col>
                        <v-col v-else cols="8"  offset="1"><a :href="'mailto:' + ownerEmail"
                            >{{ objectInfo.owner.username }}</a
                          ></v-col>
                      </v-row>
                      <v-row no-gutters class="pt-2">
                        <v-col
                          class="caption grey--text text--darken-2"
                          cols="3"
                          >{{ $t("Object type") }}</v-col
                        >
                        <v-col cols="8" offset="1">{{
                          objectInfo.cmodel
                        }}</v-col>
                      </v-row>
                      <v-row
                        v-if="objectInfo.dc_format"
                        no-gutters
                        class="pt-2"
                      >
                        <v-col
                          class="caption grey--text text--darken-2"
                          cols="3"
                          >{{ $t("Format") }}</v-col
                        >
                        <v-col cols="8" offset="1">
                          <template v-if="objectInfo.dc_format && objectInfo.dc_format.length > 1">
                            <v-row>
                              <v-col
                                v-for="(v, i) in objectInfo.dc_format"
                                :key="i"
                                >{{ v }}</v-col
                              >
                            </v-row>
                          </template>
                          <template v-else>{{
                            objectInfo.dc_format[0]
                          }}</template>
                        </v-col>
                      </v-row>
                      <v-row no-gutters class="pt-2">
                        <v-col
                          class="caption grey--text text--darken-2"
                          cols="3"
                          >{{ $t("Created") }}</v-col
                        >
                        <v-col cols="8" offset="1">{{
                          objectInfo.created | datetime
                        }}</v-col>
                      </v-row>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>

              <client-only>
                <v-row class="my-6">
                  <v-col class="pt-0">
                    <v-card tile>
                      <v-card-title
                        class="ph-box title font-weight-light grey white--text"
                      >
                        <nuxt-link
                          class="white--text"
                          :to="localePath(`/stats/${objectInfo.pid}`)"
                        >
                          {{ $t("Usage statistics") }}</nuxt-link
                        >
                      </v-card-title>
                      <v-card-text class="mt-4">
                        <v-row>
                          <v-col>
                            <v-icon>mdi-eye-outline</v-icon
                            ><span class="ml-2">{{ stats.detail }}</span>
                          </v-col>
                          <v-col v-if="downloadable">
                            <v-icon>mdi-download</v-icon
                            ><span class="ml-2">{{ stats.download }}</span>
                          </v-col>
                          <v-spacer></v-spacer>
                        </v-row>
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>
              </client-only>

              <v-row v-if="objectInfo.versions && objectInfo.versions.length > 0" class="my-6">
                <v-col class="pt-0">
                  <v-card tile>
                    <v-card-title
                      class="ph-box title font-weight-light grey white--text"
                      >{{ $t("Versions") }}</v-card-title
                    >
                    <v-card-text class="mt-4">
                      <div v-for="(rel, i) in objectInfo.versions" :key="'version' + i">
                        <v-row>
                          <v-col cols="12" md="5">{{
                            rel.created | date
                          }}</v-col>
                          <v-col cols="12" md="7">
                            <nuxt-link
                              v-if="rel['dc_title']"
                              :to="localePath(`/detail/${rel.pid}`)"
                              >{{ rel.dc_title[0] }}</nuxt-link
                            >
                            <nuxt-link
                              v-else
                              :to="localePath(`/detail/${rel.pid}`)"
                              >{{ rel.pid }}</nuxt-link
                            >
                          </v-col>
                        </v-row>
                        <v-divider
                          v-if="i + 1 < objectInfo.versions.length"
                          :key="'versiond' + i"
                        ></v-divider>
                      </div>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>

              <v-row
                v-if="objectInfo.alternativeversions && objectInfo.alternativeversions.length > 0"
                class="my-6"
              >
                <v-col class="pt-0">
                  <v-card tile>
                    <v-card-title
                      class="ph-box title font-weight-light grey white--text"
                      >{{ $t("Alternative versions") }}</v-card-title
                    >
                    <v-card-text class="mt-4">
                      <div
                        v-for="(rel, i) in objectInfo.alternativeversions"  :key="'version' + i"
                      >
                        <v-row>
                          <v-col cols="12" md="12">
                            <nuxt-link
                              v-if="rel['dc_title']"
                              :to="localePath(`/detail/${rel.pid}`)"
                              >{{ rel.dc_title[0] }}</nuxt-link
                            >
                            <nuxt-link
                              v-else
                              :to="localePath(`/detail/${rel.pid}`)"
                              >{{ rel.pid }}</nuxt-link
                            >
                          </v-col>
                        </v-row>
                        <v-divider
                          v-if="i + 1 < objectInfo.alternativeversions.length"
                          :key="'altversiond' + i"
                        ></v-divider>
                      </div>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>

              <v-row
                v-if="objectInfo.alternativeformats && objectInfo.alternativeformats.length > 0"
                class="my-6"
              >
                <v-col class="pt-0">
                  <v-card tile>
                    <v-card-title
                      class="ph-box title font-weight-light grey white--text"
                      >{{ $t("Alternative formats") }}</v-card-title
                    >
                    <v-card-text class="mt-4">
                      <div
                        v-for="(rel, i) in objectInfo.alternativeformats" :key="'format' + i"
                      >
                        <v-row>
                          <v-col cols="12" md="5"><template v-if="rel.dc_format">{{ rel.dc_format[0] }}</template></v-col>
                          <v-col cols="12" md="7">
                            <nuxt-link
                              v-if="rel['dc_title']"
                              :to="localePath(`/detail/${rel.pid}`)"
                              >{{ rel.dc_title[0] }}</nuxt-link
                            >
                            <nuxt-link
                              v-else
                              :to="localePath(`/detail/${rel.pid}`)"
                              >{{ rel.pid }}</nuxt-link
                            >
                          </v-col>
                        </v-row>
                        <v-divider
                          v-if="i + 1 < objectInfo.alternativeformats.length"
                          :key="'altformatsd' + i"
                        ></v-divider>
                      </div>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>

              <template v-if="objectInfo.relationships">
                <v-row
                  v-if="objectInfo.relationships.ispartof && objectInfo.relationships.ispartof.length > 0"
                  class="my-6"
                >
                  <v-col class="pt-0">
                    <v-card tile>
                      <v-card-title
                        class="ph-box title font-weight-light grey white--text"
                        >{{ $t("This object is in collection") }}</v-card-title
                      >
                      <v-card-text class="mt-4">
                        <div
                          v-for="(rel, i) in objectInfo.relationships.ispartof" :key="'ispartof' + i"
                        >
                          <v-row align="center">
                            <v-col cols="12" md="5" class="preview-maxwidth">
                              <p-img
                                :src="instanceconfig.api +
                                  '/object/' +
                                  rel.pid +
                                  '/thumbnail'
                                "
                                class="elevation-1 my-4"
                              ></p-img>
                            </v-col>
                            <v-col cols="12" md="7">
                              <nuxt-link
                                v-if="rel['dc_title']"
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.dc_title[0] }}</nuxt-link
                              >
                              <nuxt-link
                                v-else
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.pid }}</nuxt-link
                              >
                            </v-col>
                          </v-row>
                          <v-divider
                            :key="'ispartofd' + i"
                            v-if="
                              i + 1 < objectInfo.relationships.ispartof.length
                            "
                          ></v-divider>
                        </div>
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>

                <v-row
                  v-if="objectInfo.relationships.isbacksideof && objectInfo.relationships.isbacksideof.length > 0"
                  class="my-6"
                >
                  <v-col class="pt-0">
                    <v-card tile>
                      <v-card-title
                        class="ph-box title font-weight-light grey white--text"
                        >{{ $t("This object is a back side of") }}</v-card-title
                      >
                      <v-card-text class="mt-4">
                        <div
                          v-for="(rel, i) in objectInfo.relationships
                            .isbacksideof" :key="'isbacksideof' + i"
                        >
                          <v-row align="center">
                            <v-col cols="12" md="5" class="preview-maxwidth">
                              <p-img
                                :src="instanceconfig.api +
                                  '/object/' +
                                  rel.pid +
                                  '/thumbnail'
                                "
                                class="elevation-1 my-4"
                              ></p-img>
                            </v-col>
                            <v-col cols="12" md="7">
                              <nuxt-link
                                v-if="rel['dc_title']"
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.dc_title[0] }}</nuxt-link
                              >
                              <nuxt-link
                                v-else
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.pid }}</nuxt-link
                              >
                            </v-col>
                          </v-row>
                          <v-divider
                            :key="'isbacksideofd' + i"
                            v-if="
                              i + 1 < objectInfo.relationships.isbacksideof.length
                            "
                          ></v-divider>
                        </div>
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>

                <v-row
                  v-if="objectInfo.relationships.hasbackside && objectInfo.relationships.hasbackside.length > 0"
                  class="my-6"
                >
                  <v-col class="pt-0">
                    <v-card tile>
                      <v-card-title
                        class="ph-box title font-weight-light grey white--text"
                        >{{ $t("This object has a back side") }}</v-card-title
                      >
                      <v-card-text class="mt-4">
                        <div
                          v-for="(rel, i) in objectInfo.relationships.hasbackside" :key="'hasbackside' + i"
                        >
                          <v-row align="center">
                            <v-col cols="12" md="5" class="preview-maxwidth">
                              <p-img
                                :src="instanceconfig.api +
                                  '/object/' +
                                  rel.pid +
                                  '/thumbnail'
                                "
                                class="elevation-1 my-4"
                              ></p-img>
                            </v-col>
                            <v-col cols="12" md="7">
                              <nuxt-link
                                v-if="rel['dc_title']"
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.dc_title[0] }}</nuxt-link
                              >
                              <nuxt-link
                                v-else
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.pid }}</nuxt-link
                              >
                            </v-col>
                          </v-row>
                          <v-divider
                            :key="'hasbacksided' + i"
                            v-if="
                              i + 1 < objectInfo.relationships.hasbackside.length
                            "
                          ></v-divider>
                        </div>
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>

                <v-row
                  v-if="objectInfo.relationships.isthumbnailfor && objectInfo.relationships.isthumbnailfor.length > 0"
                  class="my-6"
                >
                  <v-col class="pt-0">
                    <v-card tile>
                      <v-card-title
                        class="ph-box title font-weight-light grey white--text"
                        >{{ $t("This object is thumbnail for") }}</v-card-title
                      >
                      <v-card-text class="mt-4">
                        <div
                          v-for="(rel, i) in objectInfo.relationships
                            .isthumbnailfor" :key="'isthumbnailfor' + i"
                        >
                          <v-row align="center">
                            <v-col cols="12" md="5" class="preview-maxwidth">
                              <p-img
                                :src="instanceconfig.api +
                                  '/object/' +
                                  rel.pid +
                                  '/thumbnail'
                                "
                                class="elevation-1 my-4"
                              ></p-img>
                            </v-col>
                            <v-col cols="12" md="7">
                              <nuxt-link
                                v-if="rel['dc_title']"
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.dc_title[0] }}</nuxt-link
                              >
                              <nuxt-link
                                v-else
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.pid }}</nuxt-link
                              >
                            </v-col>
                          </v-row>
                          <v-divider
                            :key="'isthumbnailford' + i"
                            v-if="
                              i + 1 <
                              objectInfo.relationships.isthumbnailfor.length
                            "
                          ></v-divider>
                        </div>
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>

                <v-row
                  v-if="objectInfo.relationships.hasthumbnail && objectInfo.relationships.hasthumbnail.length > 0"
                  class="my-6"
                >
                  <v-col class="pt-0">
                    <v-card tile>
                      <v-card-title
                        class="ph-box title font-weight-light grey white--text"
                        >{{ $t("This object has thumbnail") }}</v-card-title
                      >
                      <v-card-text class="mt-4">
                        <div
                          v-for="(rel, i) in objectInfo.relationships
                            .hasthumbnail" :key="'hasthumbnail' + i"
                        >
                          <v-row align="center">
                            <v-col cols="12" md="5" class="preview-maxwidth">
                              <p-img
                                :src="instanceconfig.api +
                                  '/object/' +
                                  rel.pid +
                                  '/thumbnail'
                                "
                                class="elevation-1 my-4"
                              ></p-img>
                            </v-col>
                            <v-col cols="12" md="7">
                              <nuxt-link
                                v-if="rel['dc_title']"
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.dc_title[0] }}</nuxt-link
                              >
                              <nuxt-link
                                v-else
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.pid }}</nuxt-link
                              >
                            </v-col>
                          </v-row>
                          <v-divider
                            :key="'hasthumbnaild' + i"
                            v-if="
                              i + 1 < objectInfo.relationships.hasthumbnail.length
                            "
                          ></v-divider>
                        </div>
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>

                <v-row
                  v-if="objectInfo.relationships.references && objectInfo.relationships.references.length > 0"
                  class="my-6"
                >
                  <v-col class="pt-0">
                    <v-card tile>
                      <v-card-title
                        class="ph-box title font-weight-light grey white--text"
                        >{{ $t("This object references") }}</v-card-title
                      >
                      <v-card-text class="mt-4">
                        <div
                          v-for="(rel, i) in objectInfo.relationships.references" :key="'references' + i"
                        >
                          <v-row align="center">
                            <v-col cols="12" md="5" class="preview-maxwidth">
                              <p-img
                                :src="instanceconfig.api +
                                  '/object/' +
                                  rel.pid +
                                  '/thumbnail'
                                "
                                class="elevation-1 my-4"
                              ></p-img>
                            </v-col>
                            <v-col cols="12" md="7">
                              <nuxt-link
                                v-if="rel['dc_title']"
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.dc_title[0] }}</nuxt-link
                              >
                              <nuxt-link
                                v-else
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.pid }}</nuxt-link
                              >
                            </v-col>
                          </v-row>
                          <v-divider
                            :key="'referencesd' + i"
                            v-if="
                              i + 1 < objectInfo.relationships.references.length
                            "
                          ></v-divider>
                        </div>
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>

                <v-row
                  v-if="objectInfo.relationships.isreferencedby && objectInfo.relationships.isreferencedby.length > 0"
                  class="my-6"
                >
                  <v-col class="pt-0">
                    <v-card tile>
                      <v-card-title
                        class="ph-box title font-weight-light grey white--text"
                        >{{ $t("This object is referenced by") }}</v-card-title
                      >
                      <v-card-text class="mt-4">
                        <div
                          v-for="(rel, i) in objectInfo.relationships
                            .isreferencedby" :key="'isreferencedby' + i"
                        >
                          <v-row align="center">
                            <v-col cols="12" md="5" class="preview-maxwidth">
                              <p-img
                                :src="instanceconfig.api +
                                  '/object/' +
                                  rel.pid +
                                  '/thumbnail'
                                "
                                class="elevation-1 my-4"
                              ></p-img>
                            </v-col>
                            <v-col cols="12" md="7">
                              <nuxt-link
                                v-if="rel['dc_title']"
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.dc_title[0] }}</nuxt-link
                              >
                              <nuxt-link
                                v-else
                                :to="localePath(`/detail/${rel.pid}`)"
                                >{{ rel.pid }}</nuxt-link
                              >
                            </v-col>
                          </v-row>
                          <v-divider
                            :key="'isreferencedbyd' + i"
                            v-if="
                              i + 1 <
                              objectInfo.relationships.isreferencedby.length
                            "
                          ></v-divider>
                        </div>
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>
              </template>
              <v-row class="my-6">
                <v-col class="pt-0">
                  <v-card tile>
                    <v-card-title
                      class="ph-box title font-weight-light grey white--text"
                      >{{ $t("Metadata") }}</v-card-title
                    >
                    <v-card-text class="mt-4">
                      <!-- <v-row
                        no-gutters
                        class="pt-2"
                        v-if="objectInfo.dshash['JSON-LD']"
                      >
                        <nuxt-link
                          :to="localePath(`/metadata/${objectInfo.pid}`)"
                          >{{ $t("Metadata JSON") }}</nuxt-link
                        >
                      </v-row> -->
                      <v-row
                        no-gutters
                        class="pt-2"
                        v-if="objectInfo.dshash['JSON-LD']"
                      >
                        <a
                        :href="
                            instanceconfig.api +
                            '/object/' +
                            objectInfo.pid +
                            '/json-ld'
                          "
                          target="_blank"
                          >{{ $t("JSON-LD") }}</a
                        >
                      </v-row>
                      <v-row
                        no-gutters
                        class="pt-2"
                        v-if="objectInfo.dshash['UWMETADATA']"
                      >
                        <a
                          :href="
                            instanceconfig.api +
                            '/object/' +
                            objectInfo.pid +
                            '/uwmetadata?format=xml'
                          "
                          target="_blank"
                          >{{ $t("Metadata XML") }}</a
                        >
                      </v-row>
                      <v-row
                        no-gutters
                        class="pt-2"
                        v-if="objectInfo.dshash['MODS']"
                      >
                        <a
                          :href="
                            instanceconfig.api +
                            '/object/' +
                            objectInfo.pid +
                            '/mods?format=xml'
                          "
                          target="_blank"
                          >{{ $t("Metadata XML") }}</a
                        >
                      </v-row>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>
              <v-row class="my-6">
                <v-col class="pt-0">
                  <v-card tile>
                    <v-card-title
                      class="ph-box title font-weight-light grey white--text"
                      >{{ $t("Export formats") }}</v-card-title
                    >
                    <v-card-text class="mt-4">
                      <v-row no-gutters class="pt-2">
                        <a
                          :href="
                            instanceconfig.api +
                            '/object/' +
                            objectInfo.pid +
                            '/index/dc'
                          "
                          target="_blank"
                          >{{ $t("Dublin Core") }}</a
                        >
                      </v-row>
                      <v-row
                        no-gutters
                        class="pt-2"
                      >
                        <a
                          class="mb-1"
                          :href="
                            instanceconfig.api +
                            '/object/' +
                            objectInfo.pid +
                            '/datacite?format=xml'
                          "
                          target="_blank"
                          >{{ $t("Data Cite") }}</a
                        >
                      </v-row>
                      <v-row
                        no-gutters
                        class="pt-2"
                      >
                        <a
                          class="mb-1"
                          :href="
                            instanceconfig.api +
                            '/object/' +
                            objectInfo.pid +
                            '/lom'
                          "
                          target="_blank"
                          >{{ $t("LOM") }}</a
                        >
                      </v-row>
                      <v-row
                        no-gutters
                        class="pt-2"
                      >
                        <a
                          class="mb-1"
                          :href="
                            instanceconfig.api +
                            '/object/' +
                            objectInfo.pid +
                            '/edm'
                          "
                          target="_blank"
                          >{{ $t("EDM") }}</a
                        >
                      </v-row>
                      <v-row
                        no-gutters
                        class="pt-2"
                      >
                        <a
                          class="mb-1"
                          :href="
                            instanceconfig.api +
                            '/object/' +
                            objectInfo.pid +
                            '/openaire'
                          "
                          target="_blank"
                          >{{ $t("OpenAIRE") }}</a
                        >
                      </v-row>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>

              <v-row class="my-6" v-if="objectInfo.writerights === 1">
                <v-col class="pt-0">
                  <v-card tile>
                    <v-card-title
                      class="ph-box title font-weight-light grey white--text"
                      >{{ $t("Edit") }}</v-card-title
                    >
                    <v-card-text class="mt-4">
                      <v-row
                        no-gutters
                        class="pt-2"
                        v-if="objectInfo.dshash['JSON-LD']"
                      >
                        <nuxt-link
                          :to="localePath(`/metadata/${objectInfo.pid}/edit`)"
                          >{{ $t("Edit metadata") }}</nuxt-link
                        >
                      </v-row>
                      <v-row
                        no-gutters
                        class="pt-2"
                        v-if="objectInfo.dshash['UWMETADATA']"
                      >
                        <nuxt-link
                          :to="localePath(`/uwmetadata/${objectInfo.pid}/edit`)"
                          >{{ $t("Edit metadata") }}</nuxt-link
                        >
                      </v-row>

                      <v-row
                        no-gutters
                        class="pt-2"
                      >
                        <a
                            class="mb-1"
                            @click="$refs.addcollectiondialog.open()"
                        >{{ $t("Add to collection") }}</a>
                        <collection-dialog ref="addcollectiondialog" @collection-selected="addToCollection($event)"></collection-dialog>
                      </v-row>

                      <v-row
                        v-if="objectInfo.cmodel === 'Collection'"
                        no-gutters
                        class="pt-2"
                      >
                        <v-dialog
                          v-model="collectionHelpDialog"
                          width="800"
                        >
                          <template v-slot:activator="{ on }">
                            <a
                              class="mb-1"
                              v-on="on"
                              >{{ $t("Manage members") }}</a
                            >
                          </template>
                          <v-card>
                            <v-card-title class="text-h5 grey lighten-2">
                              {{ $t("Manage members") }}
                            </v-card-title>

                            <v-card-text>
                              <p class="mt-4">{{$t('ADD_COLLECTION_MEMBERS_HELP')}}</p>
                            </v-card-text>

                            <v-divider></v-divider>

                            <v-card-actions>
                              <v-spacer></v-spacer>
                              <v-btn
                                color="primary"
                                text
                                @click="collectionHelpDialog = false"
                              >
                                OK
                              </v-btn>
                            </v-card-actions>
                          </v-card>
                        </v-dialog>
                      </v-row>
                      <v-row
                        no-gutters
                        class="pt-2"
                        v-if="
                          ((objectInfo.cmodel === 'Container') && (objectInfo.members.length <= 500 )) ||
                          ((objectInfo.cmodel === 'Collection') && ($store.state.collectionMembersTotal <= 500 ))
                        "
                      >
                        <nuxt-link
                          class="mb-1"
                          :to="localePath(`/sort/${objectInfo.pid}`)"
                          >{{ $t("Sort members (drag & drop)") }}</nuxt-link
                        >
                      </v-row>
                      <v-row
                        no-gutters
                        class="pt-2"
                        v-if="
                          objectInfo.cmodel === 'Container' ||
                          objectInfo.cmodel === 'Collection'
                        "
                      >
                        <nuxt-link
                          class="mb-1"
                          :to="localePath(`/sorttextinput/${objectInfo.pid}`)"
                          >{{ $t("Sort members (text input)") }}</nuxt-link
                        >
                      </v-row>
                      <!-- <v-row
                        no-gutters
                        class="pt-2"
                        v-if="
                          objectInfo.cmodel !== 'Container' &&
                          objectInfo.cmodel !== 'Collection' &&
                          objectInfo.cmodel !== 'Resource' &&
                          objectInfo.cmodel !== 'Book' &&
                          objectInfo.cmodel !== 'Page'
                        "
                      >
                        <nuxt-link
                          class="mb-1"
                          :to="
                            localePath(`/upload-webversion/${objectInfo.pid}`)
                          "
                          >{{ $t("Upload web-optimized version") }}</nuxt-link
                        >
                      </v-row> -->
                      <v-row
                        no-gutters
                        class="pt-2"
                        v-if="objectInfo.cmodel !== 'Page'"
                      >
                        <v-dialog
                          class="pb-4"
                          v-model="relationDialog"
                          width="800px"
                        >
                          <template v-slot:activator="{ on }">
                            <a v-on="on" class="mb-1">{{
                              $t("Upload related object")
                            }}</a>
                          </template>
                          <v-card>
                            <v-card-title
                              dark
                              class="title font-weight-light grey white--text"
                              >{{ $t("Choose relation") }}</v-card-title
                            >
                            <v-card-text>
                              <v-container>
                                <v-row align="center" justify="center">
                                  <v-col cols="12" md="4">
                                    <span>{{ $t("RELATION_SUBMITTED") }}</span>
                                  </v-col>
                                  <v-col cols="12" md="4">
                                    <v-radio-group v-model="chosenRelation">
                                      <template
                                        v-for="(r, i) in vocabularies[
                                          'relations'
                                        ].terms"
                                      >
                                        <v-radio
                                          v-if="
                                            r['@id'] ===
                                            'http://phaidra.univie.ac.at/XML/V1.0/relations#hasSuccessor'
                                          "
                                          :key="'relv' + i"
                                          :label="$t('Is new version of')"
                                          :value="
                                            r['skos:notation'][0].toLowerCase()
                                          "
                                        ></v-radio>
                                        <template
                                          v-else-if="
                                            r['@id'] ===
                                            'info:fedora/fedora-system:def/relations-external#hasCollectionMember'
                                          "
                                        >
                                          <v-radio
                                            v-if="
                                              objectInfo.cmodel === 'Collection'
                                            "
                                            :key="'relm' + i"
                                            :label="
                                              $t('Is member of collection')
                                            "
                                            :value="
                                              r[
                                                'skos:notation'
                                              ][0].toLowerCase()
                                            "
                                          ></v-radio>
                                        </template>
                                        <template
                                          v-else-if="
                                            r['@id'] ===
                                            'http://pcdm.org/models#hasMember'
                                          "
                                        >
                                          <v-radio
                                            v-if="
                                              objectInfo.cmodel === 'Container'
                                            "
                                            :key="'relcm' + i"
                                            :label="
                                              $t('Is member of container')
                                            "
                                            :value="
                                              r[
                                                'skos:notation'
                                              ][0].toLowerCase()
                                            "
                                          ></v-radio>
                                        </template>
                                        <v-radio
                                          v-else-if="r['@id'] !==
                                            'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasTrack'"
                                          :key="'rele' + i"
                                          :label="
                                            getLocalizedTermLabel(
                                              'relations',
                                              r['@id']
                                            )
                                          "
                                          :value="
                                            r['skos:notation'][0].toLowerCase()
                                          "
                                        ></v-radio>
                                      </template>
                                    </v-radio-group>
                                  </v-col>
                                  <v-col cols="12" md="4">
                                    <span
                                      >{{ objectInfo.pid }} ({{
                                        $t("this object")
                                      }})</span
                                    >
                                  </v-col>
                                </v-row>
                              </v-container>
                            </v-card-text>
                            <v-card-actions>
                              <v-spacer></v-spacer>
                              <v-btn @click="relationDialog = false">{{
                                $t("Cancel")
                              }}</v-btn>
                              <v-btn
                                class="primary"
                                :disabled="!chosenRelation"
                                @click="
                                  $router.push(
                                    localeLocation(
                                      `/submitrelated/${objectInfo.pid}/${chosenRelation}`
                                    )
                                  )
                                "
                                >{{ $t("Continue") }}</v-btn
                              >
                            </v-card-actions>
                          </v-card>
                        </v-dialog>
                      </v-row>
                      <v-row
                        no-gutters
                        class="pt-2"
                        v-if="
                          objectInfo.cmodel !== 'Container' &&
                          objectInfo.cmodel !== 'Collection'
                        "
                      >
                        <nuxt-link
                          class="mb-1"
                          :to="localePath(`/rights/${objectInfo.pid}`)"
                          >{{ $t("Access rights") }}</nuxt-link
                        >
                      </v-row>
                      <v-row no-gutters class="pt-2">
                        <nuxt-link
                          class="mb-1"
                          :to="localePath(`/relationships/${objectInfo.pid}`)"
                          >{{ $t("Relationships") }}</nuxt-link
                        >
                      </v-row>
                      <v-row v-if="(instanceconfig.showdeletebutton === 1) || (instanceconfig.showdeletebutton === true) || (user.isadmin)" no-gutters class="pt-2">
                        <nuxt-link
                          class="mb-1"
                          :to="localePath(`/delete/${objectInfo.pid}`)"
                          >{{ $t("Delete") }}</nuxt-link
                        >
                      </v-row>
                      <v-row v-if="user.isadmin" no-gutters class="pt-2">
                        <a
                          class="mb-1"
                          @click="datareplaceDialog = true"
                          >{{ $t("Replace data") }}</a
                        >
                      </v-row>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>

              <v-row justify="end" class="mb-2">
                <v-col cols="12" class="pt-0">
                  <template v-for="(md5, i) in checksums">
                    <p
                      class="text-right"
                      v-if="md5.path.includes('OCTETS')"
                      :key="'md5' + i"
                    >
                      <span class="caption text--secondary">md5</span
                      ><br /><span>{{ md5.md5 }}</span>
                    </p>
                  </template>
                </v-col>
              </v-row>
            </v-col>
          </v-row>
        </v-col>
      </v-row>
      <v-dialog v-model="datareplaceDialog" max-width="1200px">
      <v-card>
        <v-card-title>
          <h3 class="title font-weight-light primary--text">{{ $t('Upload new file to') }} {{objectInfo.pid}} ({{objectInfo.cmodel}})</h3>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-text>
          <v-container @drop.prevent="addDropFile" @dragover.prevent>
            <v-file-input v-model="datareplaceFile" :error-messages="datareplaceUploadErrors"></v-file-input>
          </v-container>
        </v-card-text>
        <v-divider></v-divider>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn text @click.stop="datareplaceDialog=false">Close</v-btn>
          <v-btn color="primary" @click="datareplaceUpload()">Upload</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    </template>
  </v-container>
</template>


<script>
import { context } from "../../mixins/context";
import { config } from "../../mixins/config";
import { vocabulary } from "phaidra-vue-components/src/mixins/vocabulary";

export default {
  mixins: [context, config, vocabulary],
  validate({ params }) {
    return /^o:\d+$/.test(params.pid);
  },
  metaInfo() {
    return this.detailsMetaInfo;
  },
  computed: {
    ownerEmail: function () {
      return this.instanceconfig.owneremailoverride ? this.instanceconfig.owneremailoverride : this.objectInfo.owner.email
    },
    collMembersPage: {
      get() {
        return this.collMembersCurrentPage;
      },
      set(value) {
        if (this.collMembersCurrentPage != value) {
          this.collMembersCurrentPage = value;
          this.$store.dispatch(
            "fetchCollectionMembers",
            { pid: this.routepid, page: this.collMembersCurrentPage, pagesize: this.collMembersPagesize }
          );
        }
      },
    },
    collMembersTotalPages: function () {
      return Math.ceil(this.$store.state.collectionMembersTotal / this.collMembersPagesize);
    },
    showPreview: function () {
      return (
        this.objectInfo.cmodel !== "Resource" &&
        this.objectInfo.cmodel !== "Collection" &&
        (this.objectInfo.cmodel !== "Asset" ||
          (this.objectInfo.cmodel === "Asset" &&
            (this.mimetype === "model/nxz" ||
              this.mimetype === "model/ply" ||
              this.mimetype === "application/x-wacz")
              )) &&
        this.objectInfo.cmodel !== "Container" &&
        this.objectInfo.readrights &&
        !(this.objectInfo.cmodel === "Video" && this.objectInfo.isrestricted)
      );
    },
    uscholarlink: function () {
      return (this.instanceconfig.irbaseurl + "/" + this.objectInfo.pid);
    },
    doi: function () {
      for (let id of this.objectInfo.dc_identifier) {
        let type = id.substr(0, id.indexOf(":"));
        let idvalue = id.substr(id.indexOf(":") + 1);
        if (type === "doi") {
          return idvalue;
        }
      }
      return null;
    },
    identifiers: function () {
      let ids = { persistent: [], other: [] };
      ids.persistent.push({
        label: "Persistent identifier",
        value: this.instanceconfig.baseurl + "/" + this.objectInfo.pid,
      });
      if (this.objectInfo.dc_identifier) {
        for (let id of this.objectInfo.dc_identifier) {
          if (id === this.instanceconfig.baseurl + "/" + this.objectInfo.pid) {
            continue;
          } else {
            let type = id.substr(0, id.indexOf(":"));
            let idvalue = id.substr(id.indexOf(":") + 1);
            switch (type) {
              case "hdl":
                ids.persistent.push({ label: "Handle", value: 'https://hdl.handle.net/' + idvalue });
                break;
              case "doi":
                let doi = idvalue
                if (!(doi.includes('https:') || doi.includes('http:'))) {
                  doi = 'https://doi.org/' + idvalue
                }
                ids.persistent.push({ label: "DOI", value: doi });
                break;
              case "urn":
                ids.persistent.push({ label: "URN", value: 'https://nbn-resolving.org/' + idvalue });
                break;
              case "issn":
                ids.persistent.push({ label: "ISSN", value: 'http://issn.org/resource/ISSN/' + idvalue });
                break;
              case "isbn":
              case "ISBN":
                ids.other.push({ label: "ISBN", value: idvalue });
                break;
              case "HTTP/WWW":
                ids.other.push({ label: "URL", value: idvalue });
                break;
              case "PrintISSN":
                ids.other.push({ label: "PrintISSN", value: idvalue });
                break;
              case "uri":
                ids.other.push({ label: "URI", value: idvalue });
                break;
              case "acnumber":
                ids.other.push({ label: "AC", value: 'https://permalink.obvsg.at/' + idvalue });
                break;
              default:
                if (idvalue.substr(0, 2) === 'AC') {
                  ids.other.push({ label: "AC", value: 'https://permalink.obvsg.at/' + idvalue });
                } else {
                  ids.other.push({ value: idvalue });
                }
                break;
            }
          }
        }
      }
      return ids;
    },
    routepid: function () {
      return this.$route.params.pid;
    },
    objectInfo: function () {
      return this.$store.state.objectInfo;
    },
    collMembers: function () {
      return this.$store.state.collectionMembers;
    },
    collMembersTotal: function () {
      // this somehow does not work on first page access
      return this.$store.state.collectionMembersTotal;
    },
    objectMembers: function () {
      return this.$store.state.objectMembers;
    },
    objectMembersPage: function () {
      if(this.objectMembers.length < this.membersPageSize) {
        return this.objectMembers
      } else {
        return this.objectMembers.slice((this.membersPage-1)*this.membersPageSize,((this.membersPage-1)*this.membersPageSize)+this.membersPageSize)
      }
    },
    downloadable: function () {
      switch (this.objectInfo.cmodel) {
        case "PDFDocument":
        case "Video":
        case "Audio":
        case "Picture":
        case "Asset":
        case "Page":
          return true;
        case "Book":
          return this.objectInfo.datastreams.includes("UWMETADATA")
        default:
          return false;
      }
    },
    hasLaterVersion: function () {
      if (this.$store.state.objectInfo.versions) {
        if (Array.isArray(this.$store.state.objectInfo.versions)) {
          for (let v of this.$store.state.objectInfo.versions) {
            if (v.created > this.$store.state.objectInfo.created) {
              return true;
            }
          }
        }
      }
      return false;
    },
    citationLocale: function () {
      switch (this.$i18n.locale) {
        case "eng":
          return "en-GB";
        case "deu":
          return "de-AT";
        case "ita":
          return "it-IT";
        default:
          return "en-GB";
      }
    },
    mimetype: function () {
      if (this.objectInfo["dc_format"]) {
        for (let f of this.objectInfo["dc_format"]) {
          if (f.includes("/")) {
            return f;
          }
        }
      }
      return "";
    },
    license: function () {
      if (this.objectInfo["dc_rights"]) {
        for (let f of this.objectInfo["dc_rights"]) {
          if (f.includes("http")) {
            return f;
          }
        }
      }
      return "";
    },
  },
  data() {
    return {
      relationDialog: false,
      doiRequestDialog: false,
      doiRequestLoading: false,
      doiCiteDialog: false,
      doiCiteLoading: false,
      citeResult: "",
      citationStyle: "apa",
      citationStyles: [],
      citationStylesLoading: false,
      chosenRelation: "http://purl.org/dc/terms/references",
      utheseslink: "",
      stats: {
        download: "-",
        detail: "-",
      },
      checksums: [],
      fullJsonLd: "",
      membersPage: 1,
      membersPageSize: 10,
      detailsMetaInfo: null,
      collectionHelpDialog: false,
      collMembersCurrentPage: 1,
      collMembersPagesize: 10,
      confirmColMemDeleteDlg: false,
      collMemberToRemove: null,
      collOnlyLatestVersions: true,
      datareplaceDialog: false,
      datareplaceFile: null,
      datareplaceUploadErrors: []
    };
  },
  async fetch() {
    await this.fetchAsyncData(this, this.$route.params.pid);
    let metaInfo = {}
    if (this.objectInfo) {
      let thumbnail =
        this.instanceconfig.api +
        "/object/" +
        this.objectInfo.pid +
        "/thumbnail";
      metaInfo.meta = [
        {
          hid: "og:title",
          name: "og:title",
          content: this.objectInfo.sort_dc_title,
        },
        {
          hid: "og:image",
          name: "og:image",
          content: thumbnail,
        },
        {
          hid: "og:image:width",
          name: "og:image:width",
          content: "1200",
        },
        {
          hid: "og:image:height",
          name: "og:image:height",
          content: "630",
        },
        {
          hid: "twitter:title",
          name: "twitter:title",
          content: this.objectInfo.sort_dc_title,
        },
        {
          hid: "twitter:card",
          name: "twitter:card",
          content: "summary_large_image",
        },
        {
          hid: "twitter:image",
          name: "twitter:image",
          content: thumbnail,
        },
      ];
      if (this.objectInfo.metatags) {
        metaInfo.title =
          this.objectInfo.metatags.citation_title +
          " (" +
          this.instanceconfig.title +
          " - " +
          this.objectInfo.pid +
          ")";
        Object.entries(this.objectInfo.metatags).forEach(([name, value]) => {
          if (Array.isArray(value)) {
            for (let v of value) {
              metaInfo.meta.push({
                name: name,
                content: v,
              });
            }
          } else {
            metaInfo.meta.push({
              name: name,
              content: value,
            });
          }
        });
      }

      // signposting
      metaInfo.link = []
      metaInfo.link.push({
        rel: 'cite-as',
        href: this.instanceconfig.baseurl + "/" + this.objectInfo.pid
      });
      if (this.objectInfo.isinadminset && this.objectInfo.edm_hastype_id) {
        if ((this.objectInfo.isinadminset.includes('phaidra:ir.univie.ac.at')) && (this.objectInfo.edm_hastype_id.includes('https://pid.phaidra.org/vocabulary/VKA6-9XTY'))) {
          metaInfo.link.push({
            rel: 'type',
            href: 'https://schema.org/ScholarlyArticle'
          });
        }
      }
      metaInfo.link.push({
        rel: 'type',
        href: 'https://schema.org/CreativeWork'
      });
      metaInfo.link.push({
        rel: 'type',
        href: 'https://schema.org/AboutPage'
      });
      metaInfo.link.push({
        rel: 'license',
        href: this.license
      });
      metaInfo.link.push({
        rel: 'describedby',
        type: 'application/xml',
        href: this.instanceconfig.api + '/object/' + this.objectInfo.pid + '/index/dc'
      });
      metaInfo.link.push({
        rel: 'describedby',
        type: 'application/vnd.datacite.datacite+xml',
        href: this.instanceconfig.api + '/object/' + this.objectInfo.pid + '/datacite?format=xml'
      });
      if (this.objectInfo.dshash['JSON-LD']) {
        metaInfo.link.push({
          rel: 'describedby',
          type: 'application/ld+json',
          href: this.instanceconfig.api + '/object/' + this.objectInfo.pid + '/json-ld'
        });
      }
      if (this.downloadable) {
        metaInfo.link.push({
          rel: 'item',
          type: this.mimetype,
          href: this.instanceconfig.api + '/object/' + this.objectInfo.pid + '/download'
        });
      }
      if (this.objectInfo.id_bib_roles_pers_aut) {
        for (let aid of this.objectInfo.id_bib_roles_pers_aut) {
          if (aid.startsWith('orcid:')) {
            metaInfo.link.push({
              rel: 'author',
              href: 'https://orcid.org/' + aid.replace('orcid:', '')
            });
          }
        }
      }
    }

    if (this.objectInfo.dshash['JSON-LD']) {
      metaInfo.script = []
      metaInfo.script.push(
        { 
          type: 'application/ld+json', 
          content: JSON.stringify(this.fullJsonLd) 
        }
      )
    }

    this.detailsMetaInfo = metaInfo
  },
  methods: {
    async fetchAsyncData(self, pid) {
      console.log('fetching object info ' + pid);
      await self.$store.dispatch("fetchObjectInfo", pid);
      self.postMetadataLoad(self);
      // console.log('cmodel: ' + self.$store.state.objectInfo.cmodel);
      if (self.$store.state.objectInfo.cmodel === "Container") {
        console.log('fetching container members ' + pid);
        await self.$store.dispatch(
          "fetchObjectMembers",
          self.$store.state.objectInfo
        );
      }
      if (self.$store.state.objectInfo.cmodel === "Collection") {
        console.log('fetching collection members ' + pid + ' page ' + self.collMembersCurrentPage + ' size ' + self.collMembersPagesize);
        await self.$store.dispatch(
          "fetchCollectionMembers",
          { pid: pid, page: self.collMembersCurrentPage, pagesize: self.collMembersPagesize, onlylatestversion: self.collOnlyLatestVersions }
        );
      }

      if (self.objectInfo.dshash['JSON-LD']) {
        try {
          let response = await self.$axios.get("/object/" + pid + "/json-ld");
          if (response.data) {
            self.fullJsonLd = response.data;
          }
        } catch (error) {
          console.log(error);
        }
      }
    },
    async refreshCollectionMembers () {
      console.log('fetching collection members ' + this.objectInfo.pid + ' page ' + this.collMembersCurrentPage + ' size ' + this.collMembersPagesize);
      await this.$store.dispatch(
        "fetchCollectionMembers",
        { pid: this.objectInfo.pid, page: this.collMembersCurrentPage, pagesize: this.collMembersPagesize, onlylatestversion: this.collOnlyLatestVersions }
      );
    },
    async fetchUsageStats(self, pid) {
      console.log("fetchUsageStats");
      self.stats.download = null;
      self.stats.detail = null;
      try {
        let response = await self.$axios.get(
          "/stats/" + pid
        );
        if (response.data.stats) {
          self.stats.download = response.data.stats.downloads;
          self.stats.detail = response.data.stats.detail_page;
        }
      } catch (error) {
        console.log(error);
      }
    },
    async fetchChecksums(self, pid) {
      try {
        let response = await self.$axios.get(
          "/object/" + pid + "/md5",
          {
            headers: {
              "X-XSRF-TOKEN": self.user.token,
            },
          }
        );
        if (response.data.md5) {
          self.checksums = response.data.md5;
        }
      } catch (error) {
        console.log(error);
      }
    },
    postMetadataLoad: function (self) {
      if (self.objectInfo) {
        if (self.objectInfo.metadata) {
          if (self.objectInfo.metadata["JSON-LD"]) {
            Object.entries(self.objectInfo.metadata["JSON-LD"]).forEach(
              ([p, arr]) => {
                if (p === "rdam:P30004") {
                  for (let o of arr) {
                    if (o["@type"] === "ids:uri") {
                      if (/utheses/.test(o["@value"])) {
                        self.utheseslink = o["@value"];
                      }
                    }
                  }
                }
              }
            );
          }
        }
      }
    },
    openDatareplace: function () {
      this.datareplaceDialog = true
    },
    datareplaceUpload: async function () {
      if (!this.datareplaceFile) {
        this.datareplaceUploadErrors.push(this.$t('Missing file'))
        return
      }
      this.$store.commit('setLoading', true)
      try {
        var httpFormData = new FormData()
        httpFormData.append('file', this.datareplaceFile)
        let response = await this.$axios.post('/object/' + this.objectInfo.pid + '/data', httpFormData, {
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        if (response.status === 200) {
          this.$store.commit('setAlerts', [{ type: 'success', msg: 'File was sucessfully uploaded' }])
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.datareplaceDialog = false
        this.$store.commit('setLoading', false)
      }
    },
    loadCitationStyles: async function () {
      this.citationStylesLoading = true;
      try {
        let response = await this.$axios.request({
          method: "GET",
          url: this.appconfig.apis.doi.citationstyles,
        });
        if (response.status !== 200) {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit("setAlerts", response.data.alerts);
          }
        } else {
          this.citationStyles = response.data;
        }
      } catch (error) {
        console.log(error);
        this.$store.commit("setAlerts", [{ type: "error", msg: error }]);
      } finally {
        this.citationStylesLoading = false;
      }
    },
    getBibTex: async function () {
      this.doiCiteLoading = true;
      try {
        let response = await this.$axios.request({
          method: "GET",
          url: "https://" + this.appconfig.apis.doi.baseurl + "/" + this.doi,
          headers: {
            Accept: "application/x-bibtex",
          },
        });
        if (response.status !== 200) {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit("setAlerts", response.data.alerts);
          }
        } else {
          this.citeResult = response.data;
        }
      } catch (error) {
        console.log(error);
        this.$store.commit("setAlerts", [{ type: "error", msg: error }]);
      } finally {
        this.doiCiteLoading = false;
      }
    },
    getCitation: async function () {
      this.doiCiteLoading = true;
      try {
        let response = await this.$axios.request({
          method: "GET",
          url: "https://" + this.appconfig.apis.doi.baseurl + "/" + this.doi,
          headers: {
            Accept:
              "text/x-bibliography; style=" +
              this.citationStyle +
              "; locale=" +
              this.citationLocale,
          },
        });
        if (response.status !== 200) {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit("setAlerts", response.data.alerts);
          }
        } else {
          this.citeResult = response.data;
        }
      } catch (error) {
        console.log(error);
        this.$store.commit("setAlerts", [{ type: "error", msg: error }]);
      } finally {
        this.doiCiteLoading = false;
      }
    },
    requestDOI: async function (self) {
      try {
        this.doiRequestDialog = false;
        this.doiRequestLoading = true;
        let response = await this.$axios.request({
          method: 'POST',
          url: '/utils/' + this.objectInfo.pid + '/requestdoi',
          headers: {
            'Content-Type': 'multipart/form-data',
            "X-XSRF-TOKEN": this.user.token,
          }
        })
        if (response.data.status === 200) {
          this.$store.commit('setAlerts', [ { msg: this.$t('DOI successfully requested'), type: 'success' } ])
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.doiRequestLoading = false
      }
    },
    resetData: function (self) {
      self.stats = {
        download: "-",
        detail: "-",
      };
      self.checksums = [];
    },
    addToCollection: async function (collection) {
      try {
        this.$store.commit('setLoading', true)
        var httpFormData = new FormData()
        httpFormData.append('metadata', JSON.stringify({ metadata: { members: [ { 'pid': this.objectInfo.pid } ] } }))
        let response = await this.$axios.request({
          method: 'POST',
          url: '/collection/' + collection.pid + '/members/add',
          headers: {
            'Content-Type': 'multipart/form-data',
            "X-XSRF-TOKEN": this.user.token,
          },
          data: httpFormData
        })
        if (response.data.status === 200) {
          this.$store.commit('setAlerts', [ { msg: this.$t('Collection successfully updated'), type: 'success' } ])
          await this.$store.dispatch(
            "fetchCollectionMembers",
            { pid: this.objectInfo.pid, page: this.collMembersCurrentPage, pagesize: this.collMembersPagesize }
          )
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.$store.commit('setLoading', false)
      }
    },
    removeFromCollection: async function () {
      try {
        this.$store.commit('setLoading', true)
        var httpFormData = new FormData()
        httpFormData.append('metadata', JSON.stringify({ metadata: { members: [ { 'pid': this.collMemberToRemove } ] } }))
        let response = await this.$axios.request({
          method: 'POST',
          url: '/collection/' + this.objectInfo.pid + '/members/remove',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.status === 200) {
          this.$store.commit('setAlerts', [ { msg: this.$t('Collection successfully updated'), type: 'success' } ])
          await this.$store.dispatch(
            "fetchCollectionMembers",
            { pid: this.objectInfo.pid, page: this.collMembersCurrentPage, pagesize: this.collMembersPagesize }
          )
          this.confirmColMemDeleteDlg = false
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.collMemberToRemove = null
        this.$store.commit('setLoading', false)
      }
    }
  },
  mounted() {
    if (this.showCollectionTree) {
      this.fetchCollectionTree(this.$route.params.pid);
      setTimeout(() => {
        this.windowWidth =
          document.getElementById("d3-graph-container").offsetWidth;
      }, 2000);
    }
  },
  beforeRouteEnter: async function (to, from, next) {
    next(async function (vm) {
      console.log('beforeRouteEnter')
      if (
        process.browser &&
        (!vm.objectInfo || vm.objectInfo.pid !== to.params.pid)
      ) {
        vm.resetData(vm);
        vm.$store.commit("setLoading", true);
        vm.$store.commit("setObjectInfo", null);
        vm.fetchChecksums(vm, to.params.pid);
        console.log("showtree:" + vm.showCollectionTree);
        vm.$store.commit("setLoading", false);
      }
      vm.fetchUsageStats(vm, to.params.pid);
    });
  },
  beforeRouteUpdate: async function (to, from, next) {
    console.log('beforeRouteUpdate')
    this.resetData(this);
    this.$store.commit("setLoading", true);
    this.$store.commit("setObjectInfo", null);
    this.fetchChecksums(this, to.params.pid);
    console.log("showtree:" + this.showCollectionTree);
    this.$store.commit("setLoading", false);
    next();
  },
};
</script>

<style lang="stylus" scoped>
@require '../../stylus/colors';

h3 {
  color: $phaidragrey.darken-4;
}
</style>

<style scoped>
.preview-maxwidth {
  max-width: 80px;
}

.container {
  padding: 0px;
}

.col-border {
  display: block;
  border: solid;
  border-width: 0 0 0 thin;
  border-color: rgba(0, 0, 0, 0.12);
  padding-top: 0px;
}

.showmembers {
  text-decoration: underline;
}

.ph-box {
  line-height: 1rem;
}

.iframe-container {
    overflow: hidden;
    padding-top: 56.25%;
    position: relative;
    width: 100%;
}

.responsive-iframe {
    position: absolute;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    width: 100%;
    height: 100%;

}
</style>
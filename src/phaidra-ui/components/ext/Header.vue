<template>
    <div v-if="instanceconfig.cms_header">
      <runtimetemplate :template="instanceconfig.cms_header" />
    </div>
    
    <div v-else>
      <v-row no-gutters class="mb-6">
          <v-col cols="12" md="10" offset-md="1" class="header py-4">
            <v-row no-gutters class="mt-2">
              <v-col class="text-left" cols="12" md="3">
                <a :href="instanceconfig.institutionurl" target="_blank" aria-label="PHAIDRA - to the homepage">
                  <svg version="1.1" id="PHAIDRA_Logo_copy_xA0_Image_1_"
                      xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 435.6 134.88"
                      style="enable-background:new 0 0 435.6 134.88; height:100px" xml:space="preserve" aria-labelledby="titleID">
                    <title id="titleID">PHAIDRA</title>
                    <style v-if="isDarkTheme" type="text/css">
                      .st0{fill:#dedede;}
                      .st1{fill:none;stroke:#dedede;stroke-width:35;stroke-miterlimit:10;}
                      .st2{fill:#dedede;}
                    </style>
                    <style v-else type="text/css">
                      .st0{fill:#212121;}
                      .st1{fill:none;stroke:#212121;stroke-width:35;stroke-miterlimit:10;}
                      .st2{fill:#222221;}
                    </style>
                    <g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M67.87,44.04c-2.96,0-5.37-2.41-5.37-5.37s2.41-5.37,5.37-5.37c2.96,0,5.37,2.41,5.37,5.37
                              S70.83,44.04,67.87,44.04z M67.87,36.82c-1.02,0-1.86,0.83-1.86,1.86s0.83,1.86,1.86,1.86s1.86-0.83,1.86-1.86
                              S68.89,36.82,67.87,36.82z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M38.97,72.95c-2.96,0-5.37-2.41-5.37-5.37c0-2.96,2.41-5.37,5.37-5.37s5.37,2.41,5.37,5.37
                              C44.33,70.54,41.93,72.95,38.97,72.95z M38.97,65.72c-1.02,0-1.86,0.83-1.86,1.86s0.83,1.86,1.86,1.86s1.86-0.83,1.86-1.86
                              S39.99,65.72,38.97,65.72z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M96.78,72.95c-2.96,0-5.37-2.41-5.37-5.37c0-2.96,2.41-5.37,5.37-5.37c2.96,0,5.37,2.41,5.37,5.37
                              C102.15,70.54,99.74,72.95,96.78,72.95z M96.78,65.72c-1.02,0-1.86,0.83-1.86,1.86s0.83,1.86,1.86,1.86s1.86-0.83,1.86-1.86
                              S97.8,65.72,96.78,65.72z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M42.58,58.5c-2.96,0-5.37-2.41-5.37-5.37s2.41-5.37,5.37-5.37s5.37,2.41,5.37,5.37S45.54,58.5,42.58,58.5z
                              M42.58,51.27c-1.02,0-1.86,0.83-1.86,1.86s0.83,1.86,1.86,1.86s1.86-0.83,1.86-1.86S43.6,51.27,42.58,51.27z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M93.16,58.5c-2.96,0-5.37-2.41-5.37-5.37s2.41-5.37,5.37-5.37c2.96,0,5.37,2.41,5.37,5.37
                              S96.12,58.5,93.16,58.5z M93.16,51.27c-1.02,0-1.86,0.83-1.86,1.86s0.83,1.86,1.86,1.86s1.86-0.83,1.86-1.86
                              S94.19,51.27,93.16,51.27z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M53.42,47.66c-2.96,0-5.37-2.41-5.37-5.37s2.41-5.37,5.37-5.37s5.37,2.41,5.37,5.37
                              S56.38,47.66,53.42,47.66z M53.42,40.43c-1.02,0-1.86,0.83-1.86,1.86s0.83,1.86,1.86,1.86s1.86-0.83,1.86-1.86
                              S54.44,40.43,53.42,40.43z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M82.32,47.66c-2.96,0-5.37-2.41-5.37-5.37s2.41-5.37,5.37-5.37c2.96,0,5.37,2.41,5.37,5.37
                              S85.28,47.66,82.32,47.66z M82.32,40.43c-1.02,0-1.86,0.83-1.86,1.86s0.83,1.86,1.86,1.86s1.86-0.83,1.86-1.86
                              S83.35,40.43,82.32,40.43z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <rect x="42.58" y="65.82" class="st0" width="50.59" height="3.51"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st1" d="M42.58,56.74"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <rect x="66.11" y="42.29" class="st0" width="3.51" height="66.85"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <polygon class="st0" points="76.04,54.88 59.7,54.88 53.76,45.97 56.69,44.02 61.58,51.37 74.16,51.37 79.06,44.02 81.98,45.97 
                                      "/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <polygon class="st0" points="55.17,67.58 51.66,67.58 51.66,61.29 44.31,56.4 46.26,53.47 55.17,59.41 				"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <polygon class="st0" points="84.08,67.58 80.57,67.58 80.57,59.41 89.48,53.47 91.43,56.4 84.08,61.29 				"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M62.4,108.78l-2.07-0.38c-6.26-1.15-12.27-3.79-17.38-7.63c-5.03-3.78-9.2-8.73-12.05-14.32l-1.31-2.56
                              h23.83c4.95,0,8.98,4.03,8.98,8.98V108.78z M35.46,87.4c5.24,8.53,13.73,14.74,23.43,17.1V92.87c0-3.02-2.45-5.47-5.47-5.47
                              H35.46z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M73.34,108.78v-15.9c0-4.95,4.03-8.98,8.98-8.98h23.83l-1.31,2.56c-2.86,5.59-7.02,10.54-12.05,14.32
                              c-5.11,3.84-11.12,6.48-17.38,7.63L73.34,108.78z M82.32,87.4c-3.02,0-5.47,2.45-5.47,5.47v11.63
                              c9.7-2.36,18.19-8.57,23.43-17.1H82.32z"/>
                          </g>
                        </g>
                      </g>
                      <g>
                        <g>
                          <g>
                            <path class="st0" d="M69.63,92.87h-3.51c0-7-5.7-12.7-12.7-12.7H28.29l-0.36-1.28c-1.04-3.67-1.56-7.47-1.56-11.32
                              c0-5.6,1.1-11.04,3.26-16.15c2.09-4.94,5.08-9.38,8.89-13.19c3.81-3.81,8.25-6.8,13.19-8.89c5.12-2.16,10.55-3.26,16.15-3.26
                              s11.04,1.1,16.15,3.26c4.94,2.09,9.38,5.08,13.19,8.89c3.81,3.81,6.8,8.25,8.89,13.19c2.16,5.12,3.26,10.55,3.26,16.15
                              c0,3.84-0.53,7.65-1.56,11.32l-0.36,1.28H82.32C75.32,80.18,69.63,85.87,69.63,92.87z M30.97,76.66h22.44
                              c6.3,0,11.77,3.61,14.45,8.87c2.68-5.26,8.15-8.87,14.45-8.87h22.44c0.73-2.96,1.09-6.01,1.09-9.08
                              c0-20.95-17.04-37.99-37.99-37.99c-20.95,0-37.99,17.04-37.99,37.99C29.88,70.66,30.25,73.71,30.97,76.66z"/>
                          </g>
                        </g>
                      </g>
                    </g>
                    <g>
                      <g>
                        <g>
                          <g>
                            <path class="st2" d="M139.3,84.84c0,1.2,0.15,2.02,0.45,2.47c0.3,0.45,0.94,0.67,1.93,0.67h0.96v0.64h-11.82v-0.64h0.9
                              c0.86,0,1.42-0.22,1.7-0.67c0.28-0.45,0.42-1.27,0.42-2.47V48.92c0-1.2-0.14-2.02-0.42-2.47c-0.28-0.45-0.85-0.67-1.7-0.67h-0.9
                              v-0.64h14.52c2.31,0,4.4,0.28,6.26,0.84c1.86,0.56,3.45,1.35,4.75,2.38c1.31,1.03,2.31,2.29,3.02,3.79
                              c0.71,1.5,1.06,3.21,1.06,5.14c0,4.03-1.41,7.15-4.24,9.38c-2.83,2.23-6.7,3.28-11.63,3.15l-5.27-0.13V84.84z M143.86,66.59
                              c3.64,0.09,6.38-0.66,8.22-2.25c1.84-1.58,2.76-3.98,2.76-7.2c0-2.87-0.95-5.09-2.86-6.65c-1.91-1.56-4.55-2.35-7.94-2.35
                              c-1.16,0-2.11,0.05-2.86,0.16c-0.75,0.11-1.38,0.33-1.9,0.67v17.48L143.86,66.59z"/>
                          </g>
                        </g>
                      </g>
                    </g>
                    <g>
                      <g>
                        <g>
                          <g>
                            <path class="st2" d="M168.16,46.45c-0.28-0.45-0.91-0.67-1.9-0.67h-0.9v-0.64h11.76v0.64h-0.9c-0.9,0-1.49,0.23-1.77,0.67
                              c-0.28,0.45-0.42,1.27-0.42,2.47v15.81h21.01V48.92c0-1.2-0.14-2.02-0.42-2.47c-0.28-0.45-0.91-0.67-1.9-0.67h-0.9v-0.64h11.82
                              v0.64h-0.9c-0.94,0-1.55,0.23-1.83,0.67c-0.28,0.45-0.42,1.27-0.42,2.47v35.92c0,1.2,0.14,2.02,0.42,2.47
                              c0.28,0.45,0.89,0.67,1.83,0.67h0.9v0.64h-11.82v-0.64h0.9c0.98,0,1.62-0.22,1.9-0.67c0.28-0.45,0.42-1.27,0.42-2.47V68.01
                              h-21.01v16.83c0,1.2,0.14,2.02,0.42,2.47c0.28,0.45,0.87,0.67,1.77,0.67h0.9v0.64h-11.76v-0.64h0.9c0.98,0,1.62-0.22,1.9-0.67
                              c0.28-0.45,0.42-1.27,0.42-2.47V48.92C168.58,47.72,168.44,46.9,168.16,46.45z"/>
                          </g>
                        </g>
                      </g>
                    </g>
                    <g>
                      <g>
                        <g>
                          <g>
                            <path class="st2" d="M253.33,88.63h-10.92v-0.64c1.03,0,1.76-0.17,2.18-0.51c0.17-0.17,0.26-0.43,0.26-0.77
                              c0.09-0.39,0-0.86-0.26-1.41l-3.98-9.77h-19.34l-3.6,9c-0.34,0.9-0.51,1.56-0.51,1.99c0,0.39,0.08,0.66,0.26,0.83
                              c0.43,0.43,1.16,0.64,2.18,0.64v0.64h-9.64v-0.64c0.94-0.08,1.76-0.47,2.44-1.16c0.68-0.68,1.26-1.56,1.73-2.63l16.45-39.52
                              h2.89l17.09,41.19c0.51,0.9,0.97,1.46,1.38,1.67c0.41,0.21,0.87,0.37,1.38,0.45V88.63z M231.04,51.43l-8.48,20.95h16.96
                              L231.04,51.43z"/>
                          </g>
                        </g>
                      </g>
                    </g>
                    <g>
                      <g>
                        <g>
                          <g>
                            <path class="st2" d="M270.25,87.32c0.28,0.45,0.95,0.67,2.02,0.67h1.03v0.64h-12.47v-0.64h1.03c1.07,0,1.75-0.22,2.02-0.67
                              c0.28-0.45,0.42-1.27,0.42-2.47V48.92c0-1.2-0.14-2.02-0.42-2.47c-0.28-0.45-0.95-0.67-2.02-0.67h-1.03v-0.64h12.47v0.64h-1.03
                              c-1.07,0-1.75,0.23-2.02,0.67s-0.42,1.27-0.42,2.47v35.92C269.84,86.04,269.98,86.87,270.25,87.32z"/>
                          </g>
                        </g>
                      </g>
                    </g>
                    <g>
                      <g>
                        <g>
                          <g>
                            <path class="st2" d="M285.51,46.45c-0.28-0.45-0.89-0.67-1.83-0.67h-0.9v-0.64h14.91c7.71,0,13.62,1.9,17.73,5.69
                              s6.17,9.18,6.17,16.16c0,6.9-2.21,12.23-6.62,16c-4.33,3.77-10.26,5.65-17.8,5.65h-14.39v-0.64h0.9c0.94,0,1.55-0.22,1.83-0.67
                              c0.28-0.45,0.42-1.27,0.42-2.47V48.92C285.92,47.72,285.78,46.9,285.51,46.45z M310.79,52.91c-3.43-3.17-8.38-4.75-14.84-4.75
                              c-1.2,0-2.14,0.1-2.83,0.29c-0.69,0.19-1.26,0.48-1.74,0.87v34.7c0.21,0.69,0.62,1.12,1.22,1.32c0.6,0.19,1.46,0.29,2.57,0.29
                              c6.81,0,11.97-1.56,15.49-4.69c3.51-3.13,5.27-7.84,5.27-14.14C315.93,60.7,314.22,56.08,310.79,52.91z"/>
                          </g>
                        </g>
                      </g>
                    </g>
                    <g>
                      <g>
                        <g>
                          <g>
                            <path class="st2" d="M335.41,84.84c0,1.2,0.14,2.02,0.42,2.47c0.28,0.45,0.91,0.67,1.9,0.67h0.9v0.64h-11.69v-0.64h0.9
                              c0.86,0,1.42-0.22,1.7-0.67c0.28-0.45,0.42-1.27,0.42-2.47V48.92c0-1.2-0.14-2.02-0.42-2.47c-0.28-0.45-0.85-0.67-1.7-0.67h-0.9
                              v-0.64h15.36c4.54,0,8.07,0.98,10.6,2.92c2.53,1.95,3.79,4.81,3.79,8.58c0,2.7-0.91,4.99-2.73,6.88
                              c-1.82,1.89-4.59,3.08-8.32,3.6c1.24,1.11,2.34,2.14,3.31,3.08s1.75,1.78,2.35,2.51c0.6,0.73,1.26,1.56,1.99,2.51
                              c0.73,0.94,1.52,1.97,2.38,3.08c0.73,0.94,1.36,1.98,1.9,3.12c0.54,1.14,1.06,2.18,1.57,3.15s1.08,1.78,1.7,2.44
                              c0.62,0.67,1.36,1,2.22,1v0.64h-7.84c-0.47-0.94-0.88-1.77-1.22-2.47s-0.74-1.47-1.19-2.28c-0.45-0.81-0.87-1.54-1.25-2.18
                              c-1.03-1.63-2.12-3.17-3.28-4.63c-1.16-1.46-2.06-2.57-2.7-3.34c-1.24-1.5-3.3-3.32-6.17-5.46l-3.98,0.06V84.84z M338.49,65.24
                              c3.9,0,6.96-0.77,9.19-2.31c2.23-1.54,3.34-3.85,3.34-6.94c0-2.7-0.9-4.68-2.7-5.94c-1.8-1.26-4.46-1.9-7.97-1.9
                              c-1.37,0-2.43,0.05-3.18,0.16c-0.75,0.11-1.34,0.42-1.77,0.93v16H338.49z"/>
                          </g>
                        </g>
                      </g>
                    </g>
                    <g>
                      <g>
                        <g>
                          <g>
                            <path class="st2" d="M409.24,88.63h-10.92v-0.64c1.03,0,1.76-0.17,2.18-0.51c0.17-0.17,0.26-0.43,0.26-0.77
                              c0.09-0.39,0-0.86-0.26-1.41l-3.98-9.77h-19.34l-3.6,9c-0.34,0.9-0.51,1.56-0.51,1.99c0,0.39,0.09,0.66,0.26,0.83
                              c0.43,0.43,1.16,0.64,2.18,0.64v0.64h-9.64v-0.64c0.94-0.08,1.76-0.47,2.44-1.16c0.69-0.68,1.26-1.56,1.74-2.63l16.45-39.52
                              h2.89l17.09,41.19c0.51,0.9,0.97,1.46,1.38,1.67c0.41,0.21,0.87,0.37,1.38,0.45V88.63z M386.94,51.43l-8.48,20.95h16.96
                              L386.94,51.43z"/>
                          </g>
                        </g>
                      </g>
                    </g>
                    <g>
                      <g>
                        <g>
                          <g>
                            <path class="st2" d="M210.69,87.99c0.51-0.08,0.98-0.24,1.38-0.45c0.41-0.21,0.87-0.77,1.38-1.67l17.09-41.19h2.89l16.45,39.52
                              c0.47,1.07,1.05,1.95,1.74,2.63c0.69,0.69,1.5,1.07,2.44,1.16v0.64h-9.64v-0.64c1.03,0,1.76-0.21,2.18-0.64
                              c0.17-0.17,0.26-0.45,0.26-0.83c0-0.43-0.17-1.09-0.51-1.99l-3.6-9h-19.34l-3.98,9.77c-0.26,0.56-0.34,1.03-0.26,1.41
                              c0,0.34,0.09,0.6,0.26,0.77c0.43,0.34,1.16,0.51,2.18,0.51v0.64h-10.92V87.99z M224.5,72.38h16.96l-8.48-20.95L224.5,72.38z"/>
                          </g>
                        </g>
                      </g>
                    </g>
                    <g>
                      <g>
                        <g>
                          <g>
                            <path class="st2" d="M366.6,87.99c0.51-0.08,0.97-0.24,1.38-0.45c0.41-0.21,0.87-0.77,1.38-1.67l17.09-41.19h2.89l16.45,39.52
                              c0.47,1.07,1.05,1.95,1.74,2.63c0.69,0.69,1.5,1.07,2.44,1.16v0.64h-9.64v-0.64c1.03,0,1.76-0.21,2.18-0.64
                              c0.17-0.17,0.26-0.45,0.26-0.83c0-0.43-0.17-1.09-0.51-1.99l-3.6-9h-19.34l-3.98,9.77c-0.26,0.56-0.34,1.03-0.26,1.41
                              c0,0.34,0.09,0.6,0.26,0.77c0.43,0.34,1.16,0.51,2.18,0.51v0.64H366.6V87.99z M380.41,72.38h16.96l-8.48-20.95L380.41,72.38z"/>
                          </g>
                        </g>
                      </g>
                    </g>
                  </svg>
                </a>
              </v-col>

              <v-col md="9">
                <v-row justify-md="end" class="px-4 py-2 py-md-0">
                  <div class="d-flex align-center me-2" v-if="signedin">
                    <v-icon
                      class="mr-1"
                      aria-hidden="true"
                    >mdi-account
                    </v-icon>
                    <span
                      class="subtitle-1"
                      >{{ user.firstname }} {{ user.lastname }}
                    </span>
                  </div>

                  <v-menu offset-y>
                    <template v-slot:activator="{ on, attrs }">
                      <v-btn text v-on="on" v-bind="attrs" aria-controls="locale-menu">                        
                        <span class="subtitle-1 text-capitalize"
                          >{{ localeLabel }}</span>
                        <v-icon
                          class="ml-1"  
                          aria-hidden="true"
                        >mdi-flag-variant
                        </v-icon>
                      </v-btn>
                    </template>
                    <v-list id="locale-menu">
                      <v-list-item
                      v-if="useLocale('eng')"
                      @click="changeLocale('eng')"
                      >
                      <v-list-item-title>English</v-list-item-title>
                      </v-list-item>
                      <v-list-item
                      v-if="useLocale('deu')"
                      @click="changeLocale('deu')"
                      >
                      <v-list-item-title>Deutsch</v-list-item-title>
                      </v-list-item>
                      <v-list-item
                        v-if="useLocale('ita')"
                        @click="changeLocale('ita')"
                        >
                        <v-list-item-title>Italiano</v-list-item-title>
                      </v-list-item>
                    </v-list>
                  </v-menu>

                  <v-tooltip v-if="!$vuetify.theme.dark" bottom>
                    <template v-slot:activator="{ on, attrs }">
                      <v-btn v-on="on" v-bind="attrs" icon @click="darkMode" :aria-label="$t('Dark Mode On')">
                        <v-icon>mdi-moon-waxing-crescent</v-icon>
                      </v-btn>
                    </template>
                    <span>{{ $t("Dark Mode On") }}</span>
                  </v-tooltip>

                  <v-tooltip v-else bottom>
                    <template v-slot:activator="{ on, attrs }">
                      <v-btn v-on="on" v-bind="attrs" icon @click="darkMode" :aria-label="$t('Dark Mode Off')">
                        <v-icon>mdi-white-balance-sunny</v-icon>
                      </v-btn>
                    </template>
                    <span>{{ $t("Dark Mode Off") }}</span>
                  </v-tooltip>
                </v-row>

                <v-row justify="center">
                  <v-col
                  v-if="appconfig.showinstanceswitch"                  
                  md="4"
                  class="select-instance text-left"
                  >
                    <v-select
                        :items="instances"
                        @input="switchInstance"
                        :value="instanceconfig.baseurl"
                        item-text="baseurl"
                        single-line
                    ></v-select>
                  </v-col>
                  <v-col                  
                  md="11"
                  offset-md="1"
                  v-else-if="instanceconfig.title"
                  >
                    <icon
                        aria-hidden="true"
                        left
                        dark
                        name="univie-right"
                        color="#a4a4a4"
                        width="14px"
                        height="14px"
                        class="mb-1"
                    ></icon>
                    <nuxt-link
                        class="subtitle-1"
                        :to="localePath('/')"
                        >{{ instanceconfig.title }}</nuxt-link
                    >
                  </v-col>
                </v-row>

                <v-row>
                  <v-toolbar flat dense color="transparent" class="my-md-1">
                    <client-only>
                      <v-row class="hidden-md-and-up">
                        <v-menu attach="#mobile-menu-btn" offset-y :disable-keys="true" min-width="150px">
                          <template v-slot:activator="{ on, attrs }">
                            <v-btn id="mobile-menu-btn" text x-large aria-controls="mobile-menu" aria-label="Main navigation menu"
                            v-bind="attrs" v-on="on" class="pa-2"><v-icon x-large class="mr-2">mdi-menu</v-icon>{{ $t('Menu') }}</v-btn>
                          </template>
                          <v-list id="mobile-menu">
                            <v-list-item
                                nuxt
                                :to="localePath({
                                    path: '/search',
                                    query: { reset: 1 },
                                    })"
                                ><v-list-item-title>{{
                                $t("Search")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="signedin"
                                nuxt
                                :to="localePath('/submit')"
                                ><v-list-item-title>{{
                                $t("Upload")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="signedin"
                                nuxt
                                :to="localePath({
                                    path: '/search',
                                    query: { reset: 1, owner: user.username },
                                    })"
                                ><v-list-item-title>{{
                                $t("My objects")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="signedin"
                                nuxt
                                :to="localePath('/lists')"
                                ><v-list-item-title>{{
                                $t("Object lists")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="signedin && instanceconfig.groups"
                                nuxt
                                :to="localePath('/groups')"
                                ><v-list-item-title>{{
                                $t("Groups")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="signedin"
                                nuxt
                                :to="localePath('/templates')"
                                ><v-list-item-title>{{
                                $t("Templates")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                nuxt
                                :to="localePath('/help')"
                                ><v-list-item-title>{{
                                $t("Help")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="!signedin && appconfig.enablelogin"
                                href
                                :to="localePath('/login')"
                                ><v-list-item-title>{{ $t("Login") }}</v-list-item-title></v-list-item
                            >
                            <v-list-item
                                v-if="user.isadmin"
                                nuxt
                                :to="localePath('/admin')"                              
                                ><v-list-item-title>{{
                                $t("Admin")
                                }}</v-list-item-title></v-list-item
                            >
                            <v-list-item v-if="signedin" @click="logout"
                                ><v-list-item-title>{{
                                $t("Logout")
                                }}</v-list-item-title></v-list-item
                            >
                          </v-list>
                        </v-menu>                                        
                      </v-row>
                    </client-only>
                    <v-spacer></v-spacer>
                    <v-toolbar-items class="hidden-sm-and-down no-height-inherit py-2">
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath({
                              path: '/search',
                              query: { reset: 1 },
                          })"
                          class="font-weight-regular white--text"                          
                        >                    
                          {{ $t("Search") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="signedin"
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath('/submit')"
                          class="font-weight-regular white--text"
                        >
                          {{ $t("Upload") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="signedin"
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath({
                              path: '/search',
                              query: { reset: 1, owner: user.username },
                          })"
                          class="font-weight-regular white--text"
                        >                    
                          {{ $t("My objects") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="signedin"
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath('/lists')"
                          class="font-weight-regular white--text"
                        >                    
                          {{ $t("Object lists") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="signedin && instanceconfig.groups"
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath('/groups')"
                          class="font-weight-regular white--text"
                        >                    
                          {{ $t("Groups") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="signedin"
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath('/templates')"
                          class="font-weight-regular white--text"
                        >                    
                          {{ $t("Templates") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn                          
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath('/help')"
                          class="font-weight-regular white--text"
                        >                    
                          {{ $t("Help") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="!signedin && appconfig.enablelogin"
                          dark
                          tile
                          depressed                          
                          :href="localePath('/login')"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          class="font-weight-regular white--text"
                          >
                            {{ $t("Login") }}                        
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="user.isadmin"
                          dark
                          tile
                          depressed
                          nuxt
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          :to="localePath('/admin')"
                          class="font-weight-regular white--text"
                          >
                            {{ $t("Admin") }}
                        </v-btn>
                      </v-hover>
                      <v-hover v-slot:default="{ hover }">
                        <v-btn
                          v-show="signedin"
                          dark
                          tile
                          depressed
                          active-class="ph-button-bg-active"
                          :color="hover ? 'primary' : isDarkTheme ? 'ph-button-bg-dark' : 'ph-button-bg'"
                          @click="logout"
                          class="font-weight-regular white--text"
                        >                    
                          {{ $t("Logout") }}
                        </v-btn>
                      </v-hover>
                    </v-toolbar-items>
                  </v-toolbar>
                </v-row>
              </v-col>
            </v-row>
          </v-col>
      </v-row>
      <a ref="logoutlink" href="/Shibboleth.sso/Logout" aria-hidden="true" role="presentation" tabindex="-1"></a>
    </div>
  </template>
  
  <script>
  import { config } from "@/mixins/config";
  import { context } from "@/mixins/context";
  
  export default {
    mixins: [config, context],
    computed: {
      localeLabel: function () {
        return this.$i18n.locale;
      },
      isDarkTheme: function () {
        return this.$vuetify.theme.dark;
      }
    },
    methods: {
      darkMode() {
        this.$vuetify.theme.dark = !this.$vuetify.theme.dark;
        localStorage.setItem("theme", this.$vuetify.theme.dark ? "dark" : "light");
        this.$cookies.set('theme', this.$vuetify.theme.dark ? "dark" : "light", {
          path: '/',
          maxAge: 60 * 60 * 24 * 365 // 1 year
        });
      },
      logout: function () {
        console.log("local logout")
        this.$store.dispatch("logout");
        this.$store.commit("setLoading", false);
        this.$router.push(this.localeLocation({ path: `/` }));
      },
      ssologoutlink: async function () {
        console.log("local logout")
        try {
          await this.$store.dispatch("logout");
        } catch (error) {
          console.log(error)
        }
        console.log("sso logout link")
        this.$store.commit("setLoading", false);
        this.$refs.logoutlink.click();
      },
      ssologout: async function () {
        console.log("local logout")
        try {
          await this.$store.dispatch("logout");
        } catch (error) {
          console.log(error)
        }
        console.log("sso logout location.href")
        this.$store.commit("setLoading", false);
        window.location.href = '/Shibboleth.sso/Logout'
      },
      useLocale: function (lang) {
        if (this.instanceconfig) {
          if (this.instanceconfig.languages) {
            return this.instanceconfig.languages.split(',').includes(lang);
          }
        }
        return false;
      },
      changeLocale: function (lang) {
        this.$i18n.locale = lang;
        // this.$i18n.setLocaleCookie(lang);
        localStorage.setItem("locale", lang);
        this.$cookies.set("locale", lang);
        this.$router.push(this.switchLocalePath(lang));
        this.$store.dispatch("vocabulary/sortRoles", this.$i18n.locale);
        this.$store.dispatch("vocabulary/sortFields", {locale: this.$i18n.locale, i18nInstance: this.$i18n});
        this.$store.dispatch("vocabulary/sortObjectTypes", this.$i18n.locale);
        this.$store.dispatch('info/sortFieldsOverview', this.$i18n.locale)
      }
    },
    mounted() {
      console.log('mounting header, signedin: ' + this.signedin)
      console.log('mounting header, token: ' + this.$store.state.user.token)
      if (localStorage.getItem("locale")) {
        this.$i18n.locale = localStorage.getItem("locale");
      } else {
        console.log('default locale: ' + this.$config.defaultLocale)
        if (this.$config.defaultLocale) {
          this.$i18n.locale = this.$config.defaultLocale
        }
        localStorage.setItem("locale", this.$i18n.locale);
        this.$cookies.set("locale", this.$i18n.locale);
      }
    }
  };
  </script>  

<style scoped>
  .ph-button:focus {
    background-color: var(--v-primary-base) !important;
    border-color: var(--v-primary-base) !important;
  }
  .ph-button {
    background-color: var(--v-cardtitlebg-base)!important;
    border-color: var(--v-cardtitlebg-base)!important;
  }

  .theme--dark .header {
    box-shadow: 48px 0 0 0 #121212, -48px 0 0 0 #121212,
    0 8px 40px -6px rgba(70, 70, 70, 0.4);
    background-color: #121212;
  }

  .v-toolbar__items .v-btn {
    margin-left: 1px;
  }

  .ph-button-bg {
    background-color: var(--v-cardtitlebg-base) !important;
    border-color: var(--v-cardtitlebg-base) !important;
  }

  .ph-button-bg-dark {
    background-color: #272727;
    border-color: #272727;
  }

  .ph-button-bg-active {
    background-color: var(--v-primary-base) !important;
    border-color: var(--v-primary-base) !important;
  }

  /* .v-btn:hover::before, .v-btn--active::before {
    opacity: 0;
  } */
</style>

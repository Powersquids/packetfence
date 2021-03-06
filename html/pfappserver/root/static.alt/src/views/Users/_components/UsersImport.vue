<template>
  <b-card no-body>
    <b-card-header>
      <h4 class="mb-0" v-t="'Import Users'"></h4>
    </b-card-header>
    <div class="card-body p-0">
      <b-tabs ref="tabs" v-model="tabIndex" card pills>
        <b-tab v-for="(file, index) in files" :key="file.name + file.lastModified"
          :title="file.name" :title-link-class="(tabIndex === index) ? ['bg-primary', 'text-light'] : ['bg-light', 'text-primary']"
          no-body
        >
          <template v-slot:title>
            <b-button-close class="ml-2" :class="(tabIndex === index) ? 'text-white' : 'text-primary'" @click.stop.prevent="closeFile(index)" v-b-tooltip.hover.left.d300 :title="$t('Close File')">
              <icon name="times" class="align-top ml-1"></icon>
            </b-button-close>
            {{ file.name }}
          </template>
          <pf-csv-import :ref="'import-' + index"
            :file="file"
            :fields="importFields"
            :events-listen="tabIndex === index"
            :is-loading="isLoading"
            :is-slot-error="invalidForm"
            :import-promise="importPromise"
            store-name="$_users"
            hover
            striped
          >
            <b-card no-body>
              <b-card-header>
                <h4 v-t="'Additional User Options'"></h4>
                <p class="mb-0" v-t="'Complete the following additional static fields.'"></p>
              </b-card-header>
              <div class="card-body">
                <b-form-group label-cols="3" :label="$t('Registration Window')">
                  <b-row>
                    <b-col>
                      <pf-form-datetime
                        :form-store-name="formStoreName" form-namespace="valid_from"
                        :min="(new Date().setHours(0,0,0,0))"
                        :config="{datetimeFormat: schema.password.valid_from.datetimeFormat}"
                      />
                    </b-col>
                    <p class="pt-2"><icon name="long-arrow-alt-right"></icon></p>
                    <b-col>
                      <pf-form-datetime
                        :form-store-name="formStoreName" form-namespace="expiration"
                        :min="(new Date().setHours(0,0,0,0))"
                        :config="{datetimeFormat: schema.password.expiration.datetimeFormat}"
                      />
                    </b-col>
                  </b-row>
                </b-form-group>
                <pf-form-fields :column-label="$t('Actions')"
                  :form-store-name="formStoreName" form-namespace="actions"
                  :button-label="$t('Add Action')"
                  :field="actionField"
                  :invalid-feedback="$t('Action(s) contain one or more errors.')"
                  sortable
                ></pf-form-fields>
                <pf-form-row align-v="start" :column-label="$t('Password Options')">
                  <b-alert show variant="info">
                    {{ $t('When no password is imported, a random password is generated using the following criteria.') }}
                  </b-alert>
                  <b-row>
                    <b-col cols="6">
                      <pf-form-input class="p-0" type="range" min="6" max="32"
                        v-model="passwordOptions.pwlength"
                        :column-label="$t('Length')"
                        :text="$t('{count} characters', { count: passwordOptions.pwlength })"
                      />
                      <pf-form-toggle
                        v-model="passwordOptions.upper"
                        :column-label="$t('Uppercase')"
                        :text="$t('Include uppercase characters')">ABC</pf-form-toggle>
                      <pf-form-toggle
                        v-model="passwordOptions.lower"
                        :column-label="$t('Lowercase')"
                        :text="$t('Include lowercase characters')">abc</pf-form-toggle>
                      <pf-form-toggle
                        v-model="passwordOptions.digits"
                        :column-label="$t('Digits')"
                        :text="$t('Include digits')">123</pf-form-toggle>
                    </b-col>
                    <b-col cols="6">
                      <pf-form-toggle
                        v-model="passwordOptions.special"
                        :column-label="$t('Special')"
                        :text="$t('Include special characters')">!@#</pf-form-toggle>
                      <pf-form-toggle
                        v-model="passwordOptions.brackets"
                        :column-label="$t('Brackets/Parenthesis')"
                        :text="$t('Include brackets')">({&lt;</pf-form-toggle>
                      <pf-form-toggle
                        v-model="passwordOptions.high"
                        :column-label="$t('Accentuated')"
                        :text="$t('Include accentuated characters')">äæ±</pf-form-toggle>
                      <pf-form-toggle
                        v-model="passwordOptions.ambiguous"
                        :column-label="$t('Ambiguous')"
                        :text="$t('Include ambiguous characters')">0Oo</pf-form-toggle>
                    </b-col>
                  </b-row>
                </pf-form-row>
              </div>
            </b-card>

          </pf-csv-import>
        </b-tab>
        <template v-slot:tabs-end>
          <pf-form-upload @files="files = $event" @focus="tabIndex = $event" :multiple="true" :cumulative="true" accept="text/*, .csv">{{ $t('Open CSV File') }}</pf-form-upload>
        </template>
        <template v-slot:empty>
          <div class="text-center text-muted">
            <b-container class="my-5">
              <b-row class="justify-content-md-center text-secondary">
                  <b-col cols="12" md="auto">
                    <icon v-if="isLoading" name="sync" scale="2" spin></icon>
                    <b-media v-else>
                      <template v-slot:aside><icon name="file" scale="2"></icon></template>
                      <h4>{{ $t('There are no open CSV files') }}</h4>
                    </b-media>
                  </b-col>
              </b-row>
            </b-container>
          </div>
        </template>
      </b-tabs>
    </div>
    <users-preview-modal v-model="showUsersPreviewModal" store-name="$_users" />
  </b-card>
</template>

<script>
import pfCSVImport from '@/components/pfCSVImport'
import pfFieldTypeValue from '@/components/pfFieldTypeValue'
import pfFormDatetime from '@/components/pfFormDatetime'
import pfFormFields from '@/components/pfFormFields'
import pfFormInput from '@/components/pfFormInput'
import pfFormRow from '@/components/pfFormRow'
import pfFormToggle from '@/components/pfFormToggle'
import pfFormUpload from '@/components/pfFormUpload'
import UsersPreviewModal from './UsersPreviewModal'
import { pfDatabaseSchema as schema } from '@/globals/pfDatabaseSchema'
import password from '@/utils/password'
import {
  userActions,
  passwordOptions,
  importFields,
  importForm, importValidators
} from '../_config/'

export default {
  name: 'users-import',
  components: {
    'pf-csv-import': pfCSVImport,
    pfFormDatetime,
    pfFormFields,
    pfFormInput,
    pfFormRow,
    pfFormToggle,
    pfFormUpload,
    UsersPreviewModal
  },
  props: {
    formStoreName: { // from router
      type: String,
      default: null,
      required: true
    }
  },
  data () {
    return {
      importFields, // ../_config/
      passwordOptions, // ../_config/
      schema, // @/globals/pfDatabaseSchema
      files: [],
      tabIndex: 0,
      actionField: {
        component: pfFieldTypeValue,
        attrs: {
          typeLabel: this.$i18n.t('Select action type'),
          valueLabel: this.$i18n.t('Select action value'),
          fields: userActions // ../_config/
        }
      },
      isLoading: false,
      showUsersPreviewModal: false,
      createdUsers: {}
    }
  },
  computed: {
    form () { // common form across all files[]
      return this.$store.getters[`${this.formStoreName}/$form`]
    },
    invalidForm () {
      return this.$store.getters[`${this.formStoreName}/$formInvalid`]
    }
  },
  methods: {
    init () {
      // setup form store module
      this.$store.dispatch(`${this.formStoreName}/setForm`, importForm)
      this.$store.dispatch(`${this.formStoreName}/setFormValidations`, importValidators)
    },
    abortFile (index) {
      this.files[index].reader.abort()
    },
    closeFile (index) {
      const file = this.files[index]
      file.close()
    },
    importPromise (payload, dryRun, done) {
      return new Promise((resolve, reject) => {
        if ('items' in payload) {
          payload.items = payload.items.map(item => { // glue payload together with local slot
            let merged = { ...item, ...this.form }
            if (!('password' in merged)) { // generate a unique password
              merged.password = password.generate(passwordOptions)
            }
            return merged
          })
        }
        this.$store.dispatch('$_users/bulkImport', payload).then(result => {
          // do something with the result, then Promise.resolve to continue processing
          if (!dryRun) {
            this.createdUsers = result.reduce((createdUsers, result) => {
              const { item } = result
              if ('pid' in item) {
                createdUsers[item.pid] = (item.pid in createdUsers)
                  ? { ...createdUsers[item.pid], ...item }
                  : item
              }
              return createdUsers
            }, this.createdUsers)
            if (done) { // processing is done
              if (Object.values(this.createdUsers).length > 0) {
                this.$store.commit('$_users/CREATED_USERS_REPLACED', Object.values(this.createdUsers))
                this.showUsersPreviewModal = true
              }
            }
          }
          resolve(result)
        }).catch(err => {
          // do something with the error, then Promise.reject to stop processing
          reject(err)
        })
      })
    }
  },
  mounted () {
    this.$store.dispatch('config/getSources')
    this.init()
  }
}
</script>

<template>
  <b-card no-body class="pf-network-graph-tooltip-switch">
    <b-card-header>
      <h5 class="mb-0 text-nowrap">{{ $t('Switch') }}</h5>
      <p class="mb-0"><mac>{{ id }}</mac></p>
    </b-card-header>
    <div class="card-body" v-if="isLoading || (!isError && Object.keys(switche).length > 0)">
      <b-container class="my-3 px-0" v-if="isLoading">
        <b-row class="justify-content-md-center text-secondary">
          <b-col cols="12" md="auto" class="w-100 text-center">
            <icon name="circle-notch" scale="2" spin></icon>
          </b-col>
        </b-row>
      </b-container>
      <b-container class="container px-0" v-else-if="!isError">
        <b-row v-if="switche.description">
          <b-col cols="auto">
            <p class="py-0 col-form-label text-left text-nowrap" v-text="'Decription'"></p>
            <p class="mb-2" v-text="switche.description"></p>
          </b-col>
        </b-row>
        <b-row v-if="switche.type">
          <b-col cols="auto">
            <p class="py-0 col-form-label text-left text-nowrap" v-text="'Type'"></p>
            <p class="mb-2" v-text="switche.type"></p>
          </b-col>
        </b-row>
      </b-container>
    </div>
  </b-card>
</template>

<script>
import apiCall from '@/utils/api'

export default {
  name: 'pf-network-graph-tooltip-switch',
  props: {
    id: {
      type: String
    },
    properties: {
      type: Object,
      default: () => { return {} }
    }
  },
  data () {
    return {
      switche: false,
      isLoading: false,
      isError: false
    }
  },
  methods: {
    init () {
      if (this.id !== 'unknown') {
        this.isLoading = true
        apiCall.getQuiet(`config/switch/${this.id}`).then(response => {
          this.switche = response.data.item
          this.isLoading = false
        }).catch(err => {
          if (Object.keys(this.properties).length > 0) {
            this.switche = this.properties // inherit properties from node
          } else {
            this.isError = err
          }
          this.isLoading = false
        })
      } else {
        // id 'unknown'
        this.switche = this.properties // inherit properties from node
      }
    }
  },
  mounted () {
    this.init()
  },
  watch: {
    id: {
      handler: function () {
        this.init()
      }
    }
  }
}
</script>

<style lang="scss">
@keyframes expandheight {
  from { overflow-y: hidden; max-height: 0px; }
  to   { overflow-y: initial; max-height: 500px; }
}

.pf-network-graph-tooltip-switch {
  .container {
    animation: expandheight 300ms;
    overflow-x: initial;
  }
}
</style>

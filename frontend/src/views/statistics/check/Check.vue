<template>
  <a-card :bordered="false" class="card-area">
    <div style="background:#ECECEC; padding:30px;margin-top: 30px;margin-bottom: 30px">
      <a-row :gutter="30">
        <a-col :span="6" v-for="(item, index) in statusList" :key="index">
          <div style="background: #e8e8e8">
            <a-carousel autoplay style="height: 150px;" v-if="splitImages(item.images).length > 0">
              <div style="width: 100%;height: 150px" v-for="(image, imageIndex) in splitImages(item.images)" :key="imageIndex">
                <img :src="buildImageUrl(image)" style="width: 100%;height: 150px">
              </div>
            </a-carousel>
            <div v-else class="space-image-placeholder">
              <a-icon type="picture" />
              <span>暂无车位图片</span>
            </div>
            <a-card :bordered="false">
              <span slot="title">
                <span style="font-size: 14px;font-family: SimHei">
                  {{ item.spaceName }} | {{ item.spaceAddress }}
                  <span style="margin-left: 15px;color: orange" v-if="item.status == -1">预约中</span>
                  <span style="margin-left: 15px;color: green" v-if="item.status == 0">空闲</span>
                  <span style="margin-left: 15px;color: red" v-if="item.status == 1">停车中</span>
                </span>
              </span>
            </a-card>
          </div>
        </a-col>
      </a-row>
    </div>
  </a-card>
</template>

<script>
export default {
  name: 'Work',
  data () {
    return {
      statusList: [],
      loading: false
    }
  },
  mounted () {
    this.getWorkStatusList()
  },
  methods: {
    splitImages (images) {
      if (!images) {
        return []
      }
      return images.split(',').map(item => item.trim()).filter(Boolean)
    },
    buildImageUrl (image) {
      if (!image) {
        return undefined
      }
      return `http://127.0.0.1:9527/imagesWeb/${image}`
    },
    getWorkStatusList () {
      this.$get(`/cos/space-status-info/status/list`).then((r) => {
        this.statusList = r.data.data
      })
    }
  }
}
</script>

<style scoped>
.space-image-placeholder {
  height: 150px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: rgba(0, 0, 0, 0.45);
  background: #f5f5f5;
}
.space-image-placeholder i {
  font-size: 28px;
  margin-bottom: 8px;
}
>>> .ant-card-meta-title {
  font-size: 13px;
  font-family: SimHei;
}
>>> .ant-card-meta-description {
  font-size: 12px;
  font-family: SimHei;
}
>>> .ant-divider-with-text-left {
  margin: 0;
}

>>> .ant-card-head-title {
  font-size: 13px;
  font-family: SimHei;
}
>>> .ant-card-extra {
  font-size: 13px;
  font-family: SimHei;
}
.ant-carousel >>> .slick-slide {
  text-align: center;
  height: 250px;
  line-height: 250px;
  overflow: hidden;
}

</style>

<template>
  <a-card :bordered="false" class="card-area">
    <div style="width: 100%">
      <a-col :span="22" v-if="newsList.length > 0">
        <a-alert
          banner
          :message="newsContent"
          type="info"
        />
      </a-col>
      <a-col :span="2">
        <a-button type="primary" style="margin-top: 2px;margin-left: 10px" @click="newsNext">下一页</a-button>
      </a-col>
    </div>
    <br/>
    <br/>
    <a-row :gutter="30" v-if="userInfo != null">
      <a-col :span="6">
        <a-card :bordered="false">
          <span slot="title">
            <a-icon type="user" style="margin-right: 10px" />
            <span>用户信息</span>
          </span>
          <div>
            <a-avatar :src="buildImageUrl(userInfo.images)" icon="user" shape="square" style="width: 100px;height: 100px;float: left;margin: 10px 0 10px 10px" />
            <div style="float: left;margin-left: 20px;margin-top: 8px">
              <span style="font-size: 20px;font-family: SimHei">{{ userInfo.name }}</span>
              <span style="font-size: 14px;font-family: SimHei">{{ userInfo.code }}</span>
            </div>
            <div style="float: left;margin-left: 20px;margin-top: 8px">
              <span style="font-size: 14px;font-family: SimHei">电话：{{ userInfo.phone == null ? '- -' : userInfo.phone }}</span>
            </div>
            <div style="float: left;margin-left: 20px;margin-top: 8px">
              <span style="font-size: 14px;font-family: SimHei">邮箱：{{ userInfo.email == null ? '- -' : userInfo.email }}</span>
            </div>
          </div>
        </a-card>
      </a-col>
    </a-row>
    <div style="background:#ECECEC; padding:30px;margin-top: 30px;margin-bottom: 30px">
      <a-row :gutter="[30, 30]">
        <a-col :xxl="8" :xl="8" :lg="8" :md="12" :sm="24" :xs="24" v-for="(item, index) in statusList" :key="index">
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
            <a-card :bordered="false" class="space-status-card">
              <span slot="title">
                <div class="space-card-title-row">
                  <div class="space-card-title-main">
                    <span class="space-card-name">{{ item.spaceName }} | {{ item.spaceAddress }}</span>
                    <span class="space-card-status reserve" v-if="item.status == -1">预约中</span>
                    <span class="space-card-status free" v-if="item.status == 0">空闲</span>
                    <span class="space-card-status busy" v-if="item.status == 1">停车中</span>
                  </div>
                  <a class="space-card-action" v-if="item.status == 0" @click="showModal(item)">
                    <a-icon type="paper-clip" />预约
                  </a>
                </div>
              </span>
            </a-card>
          </div>
        </a-col>
      </a-row>
      <a-modal
        title="选择预定车辆"
        :visible="visible"
        @ok="reserveSpace"
        @cancel="handleCancel"
      >
        <a-form :form="form" layout="vertical">
          <a-row :gutter="20">
            <a-col :span="24">
              <a-form-item label='车辆信息' v-bind="formItemLayout">
                <a-radio-group button-style="solid" v-decorator="[
                    'vehicleId',
                    {rules: [{ required: true, message: '请选择车辆' }]}
                  ]">
                  <a-radio-button :value="item.id" v-for="(item, index) in vehicleList" :key="index">
                    {{ item.vehicleNumber }}
                  </a-radio-button>
                </a-radio-group>
              </a-form-item>
            </a-col>
          </a-row>
        </a-form>
      </a-modal>
    </div>
  </a-card>
</template>

<script>
import {mapState} from 'vuex'

const formItemLayout = {
  labelCol: { span: 24 },
  wrapperCol: { span: 24 }
}
export default {
  name: 'Work',
  data () {
    return {
      form: this.$form.createForm(this),
      formItemLayout,
      visible: false,
      statusList: [],
      vehicleList: [],
      loading: false,
      newsContent: '',
      newsPage: 0,
      userInfo: null,
      memberInfo: null,
      spaceInfo: null,
      newsList: []
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.account.user
    })
  },
  mounted () {
    this.getWorkStatusList()
    this.selectMemberByUserId()
    this.selectVehicleByUserId()
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
    newsNext () {
      if (this.newsPage + 1 === this.newsList.length) {
        this.newsPage = 0
      } else {
        this.newsPage += 1
      }
      this.newsContent = `《${this.newsList[this.newsPage].title}》 ${this.newsList[this.newsPage].content}`
    },
    showModal (row) {
      this.spaceInfo = row
      this.form.resetFields()
      this.visible = true
    },
    handleCancel () {
      this.form.resetFields()
      this.visible = false
    },
    selectVehicleByUserId () {
      this.$get(`/cos/vehicle-info/user/${this.currentUser.userId}`).then((r) => {
        this.vehicleList = r.data.data
      })
    },
    reserveSpace () {
      this.form.validateFields((err, values) => {
        if (!err) {
          values.spaceId = this.spaceInfo.id
          this.$post('/cos/reserve-info', {
            ...values
          }).then((r) => {
            this.$message.success('预约成功！预约时间为30分钟')
            this.form.resetFields()
            this.visible = false
            this.getWorkStatusList()
          })
        }
      })
    },
    selectMemberByUserId () {
      this.$get(`/cos/member-info/member/${this.currentUser.userId}`).then((r) => {
        this.userInfo = r.data.user
        this.memberInfo = r.data.member
        this.newsList = r.data.bulletin
        if (this.newsList.length !== 0) {
          this.newsContent = `《${this.newsList[0].title}》 ${this.newsList[0].content}`
        }
      })
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
>>> .space-status-card .ant-card-head-title {
  white-space: normal;
  overflow: visible;
  text-overflow: clip;
  padding: 0;
}
.space-card-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  width: 100%;
}
.space-card-title-main {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
  flex-wrap: wrap;
}
.space-card-name {
  font-size: 14px;
  font-family: SimHei;
  color: rgba(0, 0, 0, 0.88);
}
.space-card-status {
  font-size: 14px;
  font-family: SimHei;
  font-weight: 600;
}
.space-card-status.reserve {
  color: orange;
}
.space-card-status.free {
  color: #2f9e44;
}
.space-card-status.busy {
  color: #fa5252;
}
.space-card-action {
  flex-shrink: 0;
  display: inline-flex;
  align-items: center;
  gap: 4px;
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

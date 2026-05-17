export const validate = {
  phone(rule, value, callback) {
    const phoneReg = /^1[3-9]\d{9}$/
    if (!value) {
      callback(new Error('请输入手机号码'))
    } else if (!phoneReg.test(value)) {
      callback(new Error('请输入正确的手机号码'))
    } else {
      callback()
    }
  },
  idCard(rule, value, callback) {
    const idCardReg = /^\d{17}[\dXx]$|^\d{15}$/
    if (!value) {
      callback(new Error('请输入身份证号'))
    } else if (!idCardReg.test(value)) {
      callback(new Error('请输入正确的身份证号'))
    } else {
      callback()
    }
  },
  email(rule, value, callback) {
    const emailReg = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
    if (!value) {
      callback(new Error('请输入邮箱'))
    } else if (!emailReg.test(value)) {
      callback(new Error('请输入正确的邮箱格式'))
    } else {
      callback()
    }
  },
  password(rule, value, callback) {
    if (!value) {
      callback(new Error('请输入密码'))
    } else if (value.length < 6) {
      callback(new Error('密码长度不能少于6位'))
    } else {
      callback()
    }
  },
  username(rule, value, callback) {
    if (!value) {
      callback(new Error('请输入用户名'))
    } else if (value.length < 3) {
      callback(new Error('用户名长度不能少于3位'))
    } else {
      callback()
    }
  }
}

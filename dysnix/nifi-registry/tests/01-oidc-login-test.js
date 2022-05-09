const { it } = require('mocha')
const puppeteer = require ('puppeteer-core')
const expect = require('chai').expect

describe('NiFi Registry Login via OIDC', () => {
    let browser
    let page

    before(async () => {
        browser = await puppeteer.connect({
          browserWSEndpoint: 'ws://'+process.env.K8SNODEIP+':'+process.env.K8SPORT,
          ignoreHTTPSErrors: true
        })
        page = await browser.newPage()
        await page.setViewport({ width: 1280, height: 1024 })
    })

    it('NiFi Registry shows anonymous logged in', async() => {
        let gotoSucceeded = false
        for ( let i = 0; ( i < 60 ) && ( ! gotoSucceeded ); i++) {
            try {
                await Promise.all([
                    page.goto(process.env.NIFIREGURL),
                    page.waitForNavigation(),
                    page.waitForNetworkIdle()
                ])
                gotoSucceeded = true
            }
            catch (err) {
                console.log("        Connection to "+process.env.NIFIURL+"failed: "+err.message+" ( try "+i.toString()+")")
                await page.waitForTimeout(5000)
            }
        }
        const currentUser = await page.waitForSelector('div[id="current-user"]')
        const userName = await currentUser.evaluate(el => el.textContent)
        expect(userName).to.include('anonymous')
    }).timeout(30000)

    it('Get screenshot of anonymous logged in', async() => {
        await page.screenshot({
            path: process.env.HOME+"/screenshots/0101-anonymous-logged-in.png",
            fullPage: true
        })
    })

    it('Click login and go to Keycloak login screen', async() => {
        await Promise.all([
            page.click('a[id="login-link-container"]'),
            page.waitForNavigation(),
            page.waitForNetworkIdle()
        ])
        const pageTitle = await page.waitForSelector('h1[id="kc-page-title"]')
        const titleContent = await pageTitle.evaluate(el => el.textContent)
        expect(titleContent).to.include('Sign in to your account')
    })

    it('Get screenshot of Keycloak login screen', async() => {
        await page.screenshot({
            path: process.env.HOME+"/screenshots/0102-keycloak-login-screen.png",
            fullPage: true
        })
    })

    it('NiFi User shown as logged in user', async () => {
        await page.type('input[id="username"]','nifi')
        await page.type('input[id="password"]','reallychangeme')
        await Promise.all([
            page.click('input[id="kc-login"]'),
            page.waitForNavigation(),
            page.waitForNetworkIdle()
        ])
        const currentUser = await page.waitForSelector('div[id="current-user"]')
        const userName = await currentUser.evaluate(el => el.textContent)
        expect(userName).to.include('NiFi User')
    }).timeout(300000)

    it('Get screenshot of NiFi User logged in', async () => {
        await page.screenshot({
            path: process.env.HOME+"/screenshots/0103-logged-in-user.png",
            fullPage: true
        })
    })

    it('Confirm settings wrench available', async () => {
        await page.waitForSelector('button[mattooltip="Settings"]')
    }).timeout(5000)

    after(async () => {
        await browser.close()
    })
})

const { it } = require('mocha')
const puppeteer = require ('puppeteer-core')
const expect = require('chai').expect

describe('NiFi Registry Create Bucket', () => {
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

    it('Get screenshot of anonymous user', async () => {
        await page.screenshot({
            path: process.env.HOME+"/screenshots/0201-anonymous-user.png",
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

    it('Get screenshot of Keycloak login page', async () => {
        await page.screenshot({
            path: process.env.HOME+"/screenshots/0202-keycloak-redirect.png",
            fullPage: true
        })
    })

    it('Log in as nifi@example.com', async () => {
        await page.type('input[id="username"]','nifi')
        await page.type('input[id="password"]','reallychangeme')
        await Promise.all([
            page.click('input[id="kc-login"]'),
            page.waitForNavigation(),
            page.waitForNetworkIdle()
        ])
        const currentUser = await page.waitForSelector('div[id="current-user"]')
        const userName = await currentUser.evaluate(el => el.textContent)
        expect(userName).to.include('nifi@example.com')
    }).timeout(300000)

    it('Get screenshot of logged in user', async () => {
        await page.screenshot({
            path: process.env.HOME+"/screenshots/0203-logged-in-user.png",
            fullPage: true
        })
    })

    it('Confirm settings wrench available', async () => {
        await page.waitForSelector('button[mattooltip="Settings"]')
    }).timeout(5000)

    it('Open settings and look for new bucket button', async() => {
        await Promise.all([
            page.click('button[mattooltip="Settings"]'),
            page.waitForNavigation(),
            page.waitForNetworkIdle()
        ])
        const newBucketButton = await page.waitForSelector('button[data-automation-id="new-bucket-button"]')
        const buttonText = await newBucketButton.evaluate(el => el.textContent)
        expect(buttonText).to.include('New Bucket')
    }).timeout(300000)

    it('Click new bucket button', async() => {
        await Promise.all([
            page.click('button[data-automation-id="new-bucket-button"]'),
            page.waitForNetworkIdle()
        ])
    })

    it('Fill in bucket name and description', async() => {
        await Promise.all([
            await page.type('input[data-placeholder="Bucket Name"]','foo'),
            await page.type('input[data-placeholder="Description"]','pity da')
        ])
    })

    it('Get screenshot after filling in', async() => {
        await page.screenshot({
            path: process.env.HOME+"/screenshots/0204-filling-in.png",
            fullPage: true
        })
    })

    it('Click create new bucket button', async() => {
        await Promise.all([
            page.click('button[data-automation-id="create-new-bucket-button"]'),
            page.waitForNetworkIdle()
        ])
    })

    it('Get screenshot after creating new bucket', async() => {
        await page.screenshot({
            path: process.env.HOME+"/screenshots/0205-created-new-bucket.png",
            fullPage: true
        })
    })

    after(async () => {
        await browser.close()
    })
})

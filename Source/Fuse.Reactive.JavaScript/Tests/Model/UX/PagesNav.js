class Page1 {}
class Page2 {}

class PagesNav {
    constructor() {
        this.pages = [ new Page1() ];
    }

    gotoPage2() {
        this.pages.push(new Page2());
    }

    goBack() {
        this.pages.pop();
    }

    gotoPage2Rewrite() {
        this.pages = this.pages.concat(new Page2());
    }

    goBackRewrite() {
        this.pages = [ new Page1() ];
    }

}

module.exports = PagesNav;
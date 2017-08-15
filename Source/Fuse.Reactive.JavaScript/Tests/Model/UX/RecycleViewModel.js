class WelcomePage {

}

class FirstPage {

}

class SecondPage
{

}

class RecycleViewModel {
    constructor() {
        this.firstPage = new FirstPage();
        this.pages = [ new WelcomePage()  ];
        this.innerPage = "DummyPage";
    }

    gotoFirstPage() {
        console.log("Going to first page");
        this.pages = [ this.firstPage ];
    }

    gotoSecondPage() {
        console.log("Going to second");
        this.pages = this.pages.concat(new SecondPage());
    }

    goBack() {
        console.log("Going back");
        this.pages = [ this.firstPage ];
    }
}

module.exports = RecycleViewModel;
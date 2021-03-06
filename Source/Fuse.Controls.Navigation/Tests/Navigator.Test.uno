using Uno;
using Uno.Collections;
using Uno.Testing;
using Uno.UX;

using FuseTest;

using Fuse.Controls;
using Fuse.Elements;
using Fuse.Triggers;

namespace Fuse.Navigation.Test
{
	public class NavigatorTest : TestBase
	{	
		//only a few tests use this, the rest turn off the prepare busy mechanism
		void WaitPrepare(TestRootPanel root)
		{	
			//we know pages take at most two-frames to be prepared
			root.IncrementFrame(); 
			root.IncrementFrame(); 
		}
		
		void WaitPrepareJS(TestRootPanel root)
		{	
			root.StepFrameJS(); 
			root.StepFrameJS(); 
		}
		
		[Test]
		public void Reuse()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.Reuse();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				p.router.Goto( new Route("One", "A"));
				WaitPrepare(root);
				var act = p.nav.Active;
				p.router.Goto( new Route("One", "B"));
				WaitPrepare(root);
				Assert.AreEqual(act, p.nav.Active);
				
				p.router.Goto( new Route("Two", "A"));
				WaitPrepare(root);
				act = p.nav.Active;
				p.router.Goto( new Route("Two", "B"));
				WaitPrepare(root);
				Assert.AreNotEqual(act, p.nav.Active);
			}
		}
		
		[Test]
		public void ReuseNoneRemove()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.ReuseNoneRemove();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				p.router.Goto( new Route("One", "A"));
				root.PumpDeferred();
				var act1 = p.nav.Active;
				p.router.Push( new Route("Two", "B"));
				root.PumpDeferred();
				var act2 = p.nav.Active;
				
				root.StepFrame(5); //stabilize anim
				Assert.IsTrue( p.nav.Children.Contains(act1) );
				
				p.router.Push( new Route("One", "C"));
				root.PumpDeferred();
				var act3 = p.nav.Active;
				Assert.AreEqual(act1,act3);
				
				root.StepFrame(5);
				Assert.IsFalse(p.nav.Children.Contains(act2));
				
				p.router.Push( new Route( "Two", "D" ) );
				root.PumpDeferred();
				var act4 = p.nav.Active;
				Assert.AreNotEqual( act2, act4 );
				
				root.StepFrame(5);
				Assert.IsTrue(p.nav.Children.Contains(act1));
			}
		}
		
		[Test]
		public void ReuseInactive()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.ReuseInactive();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				//no reuse
				p.router.Goto( new Route("Two", "A"));
				root.PumpDeferred();
				var a = p.nav.Active;
				root.StepFrame(2); //stabilize
				p.router.Push( new Route("Two", "B"));
				root.PumpDeferred();
				var b = p.nav.Active;
				Assert.AreNotEqual(a, p.nav.Active);
				
				root.StepFrame(2); 
				p.router.Push( new Route("Two", "C"));
				root.PumpDeferred();
				Assert.AreNotEqual(a, p.nav.Active);
				Assert.AreNotEqual(b, p.nav.Active);

				//inactive
				p.router.Goto( new Route("One", "A"));
				root.PumpDeferred();
				a = p.nav.Active;
				root.StepFrame(2); //stabilize
				p.router.Push( new Route("One", "B"));
				root.PumpDeferred();
				b = p.nav.Active;
				Assert.AreNotEqual(a, p.nav.Active); //must be two present, so it can't reuse a yet
				
				root.StepFrame(2); 
				p.router.Push( new Route("One", "C"));
				root.PumpDeferred();
				Assert.AreEqual(a, p.nav.Active);
			}
		}
		
		[Test]
		public void ReuseRemoved()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.ReuseRemoved();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				//no reuse
				p.router.Goto( new Route("One", "A"));
				root.PumpDeferred();
				var a = p.nav.Active;
				root.StepFrame(2); //stabilize
				
				p.router.Push( new Route("One", "B"));
				root.PumpDeferred();
				var b = p.nav.Active;
				Assert.AreNotEqual(a, p.nav.Active);
				root.StepFrame(2); 
				
				p.router.Push( new Route("One", "C"));
				root.PumpDeferred();
				var c = p.nav.Active;
				Assert.AreNotEqual(a, c);
				Assert.AreNotEqual(b, c);

				//reuse removed
				p.router.Goto( new Route("One", "D"));
				root.PumpDeferred();
				//Assert.AreEqual(a, p.nav.Active); //WHITE-BOX: the navigator doesn't reuse immediately
				root.StepFrame(2); //stabilize
				p.router.Push( new Route("One", "E"));
				root.PumpDeferred();
				Assert.AreEqual(a, p.nav.Active); //WHITE-BOX: this could also be `b`
			}
		}
		
		[Test]
		public void Remove()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.Remove();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				p.router.Goto( new Route("One","A"));
				WaitPrepare(root);
				var a = p.nav.Active;
				root.StepFrame(2); //stabilize
				
				
				p.router.Push( new Route("Two","B"));
				WaitPrepare(root);
				var b = p.nav.Active;
				root.StepFrame(2);
				
				Assert.IsTrue(p.nav.Children.Contains(a));
				Assert.IsTrue(p.nav.Children.Contains(b));
				
				
				p.router.Push( new Route("Three", "C"));
				root.PumpDeferred();
				var c = p.nav.Active;
				root.StepFrame(2);
				
				Assert.IsTrue(p.nav.Children.Contains(a));
				Assert.IsFalse(p.nav.Children.Contains(b));
				Assert.IsTrue(p.nav.Children.Contains(c));
				
				//clear the old pages
				p.router.Goto( new Route("Two", "D"));
				WaitPrepare(root);
				var d = p.nav.Active;
				root.StepFrame(2);
				
				Assert.IsFalse(p.nav.Children.Contains(a));
				Assert.IsFalse(p.nav.Children.Contains(b));
				Assert.IsTrue(p.nav.Children.Contains(c));
				Assert.IsTrue(p.nav.Children.Contains(d));
			}
		}
		
		[Test]
		public void DeferredActivation()
		{	
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.DeferredActivation();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				p.GoSearch.Perform();
				root.StepFrameJS();
				//should need at most one more frame for activations
				root.IncrementFrame();
				
				var search = p.Nav.FirstChild<Search>();
				Assert.AreEqual(1, search.TA.PerformedCount);
				Assert.AreEqual(1, search.TB.PerformedCount);
			}
		}
		
		[Test]
		//https://github.com/fusetools/fuselibs/issues/2982
		public void EmptyParameter()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.EmptyParameter();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				WaitPrepareJS(root);
				var f = p.N.Active;
				
				p.GoA.Perform();
				WaitPrepareJS(root);
				Assert.AreEqual(f, p.N.Active);
				
				p.GoB.Perform();
				WaitPrepareJS(root);
				Assert.AreEqual(f, p.N.Active);
				
				//should be new (sanity test)
				p.GoE.Perform();
				WaitPrepareJS(root);
				Assert.AreNotEqual(f, p.N.Active);
				
				root.StepFrame(5); //stabilize
				p.GoC.Perform();
				WaitPrepareJS(root);
				Assert.AreEqual(f, p.N.Active);
				
				p.GoD.Perform();
				WaitPrepareJS(root);
				Assert.AreEqual(f, p.N.Active);
			}
		}

		[Test]
		public void PageBinding()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.Page();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				root.StepFrameJS();
				
				Assert.AreEqual( "One", p.theText.Value );
				
				p.goP2.Perform();
				root.StepFrameJS();
				//page change is immediate
				Assert.AreEqual( "Two", p.theText.Value );
			}
		}
		
		[Test]
		public void NonTemplates()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.NonTemplate();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				var one1 = p.theNav.Active;
				p.PushP1.Perform();
				root.StepFrameJS();
				
				var one2 = p.theNav.Active;
				Assert.IsFalse(one1 == one2);
				Assert.AreEqual( "\"1\"", one2.Parameter );
				
				p.PushP2.Perform();
				root.StepFrameJS();
				var two1 = p.theNav.Active;
				Assert.AreEqual( "\"2\"", two1.Parameter );
				
				p.PushP2.Perform();
				root.StepFrameJS();
				var two2 = p.theNav.Active;
				Assert.AreEqual(two1, two2);
				Assert.AreEqual( "\"3\"", two2.Parameter );
				
				p.router.GoBack();
				Assert.AreEqual( "\"2\"", two1.Parameter );
			}
		}
		
		[Test]
		public void JsInterface()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.JsInterface();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				p.SeekToP2.Perform();
				root.StepFrameJS();
				Assert.AreEqual( p.P2, p.theNav.Active );
				Assert.AreEqual( "\"1\"", p.theNav.Active.Parameter );
				root.StepFrame(0.1f);
				Assert.AreEqual( 0, TriggerProgress(p.T1) );
				
				p.GotoP1.Perform();
				root.StepFrameJS();
				Assert.AreEqual( "\"2\"", p.theNav.Active.Parameter );
				root.StepFrame(0.1f);
				Assert.AreEqual( 0.9f, TriggerProgress((p.theNav.Active as JIPageOne).T1),
					Assert.ZeroTolerance + root.StepIncrement);
			}
		}
		
		[Test]
		//https://github.com/fusetools/support-idesse/issues/3
		public void RootingCache()
		{
			Router.TestClearMasterRoute();
			var p =  new UX.Navigator.RootingCache();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				p.R.Goto( new Route( "one" ) );
				root.StepFrame(5); //stabilize navigator animations
				p.R.Push( new Route( "two" ) );
				root.StepFrame(5);
				p.R.GoBack();
				root.StepFrame(5);
				
				p.Children.Remove(p.N);
				root.IncrementFrame();
				p.Children.Add(p.N);
				root.PumpDeferred();
				
				//white box: other pages are removed from the cache, it's actually undefined if they are removed
				//or simply the state updated
				var c = GetChildren<RCPage>(p.N);
				Assert.AreEqual(1, c.Count);
				Assert.AreEqual("one", c[0].Title);
				Assert.AreEqual(1, TriggerProgress(c[0].A));
			}
		}
		
		[Test]
		//variant of RootingCache that uses non-template pages
		public void RootingCache2()
		{
			Router.TestClearMasterRoute();
			var p =  new UX.Navigator.RootingCache2();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				p.R.Goto( new Route( "one" ) );
				root.StepFrame(5); //stabilize navigator animations
				p.R.Push( new Route( "two" ) );
				root.StepFrame(5);
				p.R.GoBack();
				root.StepFrame(5);
				
				Assert.AreEqual(1, TriggerProgress(p.one.A));
				Assert.AreEqual(0, TriggerProgress(p.two.A));
				
				p.Children.Remove(p.N);
				root.IncrementFrame();
				p.Children.Add(p.N);
				root.PumpDeferred();
				
				Assert.AreEqual(1, TriggerProgress(p.one.A));
				Assert.AreEqual(0, TriggerProgress(p.two.A));
			}
		}
		
		[Test]
		public void SwipeBack()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.SwipeBack();
			using (var root = TestRootPanel.CreateWithChild(p,int2(1000)))
			{
				var one = p.Nav.Active;
				p.R.Push( new Route("two"));
				root.StepFrame(5); //stabilize navigator animations
				
				//don't swipe far enough
				var two = p.Nav.Active;
				root.PointerSwipe(float2(100,100), float2(150,100), 50); //too slow to trigger velocity
				root.StepFrame(5);

				Assert.AreEqual(two, p.Nav.Active);
				Assert.AreEqual(1, p.R.TestHistoryCount);
				
				//now swipe far enough
				root.PointerSwipe(float2(100,100), float2(400,100));
				root.StepFrame(5);
				
				Assert.AreEqual(one, p.Nav.Active);
				Assert.AreEqual(0, p.R.TestHistoryCount);
				
				p.R.Push( new Route("three") );
				root.StepFrame(5); 
				var three = p.Nav.Active;
				Assert.AreEqual("Three", (three as Page).Title);
				
				//swipe disabled on page
				root.PointerSwipe(float2(100,100), float2(400,100));
				root.StepFrame(5);
				
				Assert.AreEqual(three, p.Nav.Active);
				Assert.AreEqual(1, p.R.TestHistoryCount);
			}
		}
		
		[Test]
		public void SwipeBackDirection()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.SwipeBackDirection();
			using (var root = TestRootPanel.CreateWithChild(p,int2(1000)))
			{
				var one = p.Nav.Active;
				p.R.Push( new Route("two"));
				root.StepFrame(5); //stabilize navigator animations
				var two = p.Nav.Active;
				
				p.R.Push( new Route("three"));
				root.StepFrame(5);
				
				//swipe left here to go back
				root.PointerSwipe(float2(400,100), float2(100,100));
				root.StepFrame(5);
				
				Assert.AreEqual(two, p.Nav.Active);
				Assert.AreEqual(1, p.R.TestHistoryCount);
				
				//swipe right here to go back
				root.PointerSwipe(float2(100,100), float2(400,100));
				root.StepFrame(5);
				
				Assert.AreEqual(one, p.Nav.Active);
				Assert.AreEqual(0, p.R.TestHistoryCount);
			}
		}
		
		[Test]
		//tests null paths and swiping back to them
		public void SwipeBackNull()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.SwipeBackNull();
			using (var root = TestRootPanel.CreateWithChild(p,int2(1000)))
			{
				Assert.AreEqual( "", p.R.GetCurrentRoute().Format() );
				p.R.Push( new Route( "a" ) );
				root.PumpDeferred();
				Assert.AreEqual( "a/", p.R.GetCurrentRoute().Format() );
				
				p.R.Push( new Route( "a", null, new Route( "one" ) ) );
				root.PumpDeferred();
				Assert.AreEqual( "a/one", p.R.GetCurrentRoute().Format() );
				Assert.AreEqual(2, p.R.TestHistoryCount);
				Assert.AreEqual(p.one, p.Nav.Active);
				
				root.PointerSwipe(float2(100,100), float2(100,400));
				root.StepFrame(5);
				Assert.AreEqual( "a/", p.R.GetCurrentRoute().Format() );
				Assert.AreEqual(1, p.R.TestHistoryCount);
				Assert.AreEqual(null, p.Nav.Active);
				
				root.PointerSwipe(float2(100,100), float2(100,400));
				root.StepFrame(5);
				Assert.AreEqual( "", p.R.GetCurrentRoute().Format() );
				Assert.AreEqual(0, p.R.TestHistoryCount);
				Assert.AreEqual(null, p.NavO.Active);
			}
		}
		
		[Test]
		//an explicit NavigatorSwipe to work with bookmarks
		public void SwipeBookmark()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.SwipeBookmark();
			using (var root = TestRootPanel.CreateWithChild(p,int2(1000)))
			{
				root.StepFrameJS();
				
				root.PointerSwipe(float2(100,400), float2(100,100));
				root.StepFrame(5);
				Assert.AreEqual( "two", p.R.GetCurrentRoute().Format() );
				Assert.AreEqual(1, p.R.TestHistoryCount);
				
				root.PointerSwipe(float2(100,100), float2(100,400));
				root.StepFrame(5);
				Assert.AreEqual( "one", p.R.GetCurrentRoute().Format() );
				Assert.AreEqual(0, p.R.TestHistoryCount); //was goto
			}
		}
		
		[Test]
		//constructs the swiping logic at the UX level
		public void SwipeBits()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.SwipeBits();
			using (var root = TestRootPanel.CreateWithChild(p,int2(10000)))
			{
				root.StepFrameJS();
				Assert.AreEqual( "one/one", p.R.GetCurrentRoute().Format());
				
				p.R.Push( new Route( "one", null, new Route( "two" ) ) );
				root.StepFrame(5);
				Assert.AreEqual( "one/two", p.R.GetCurrentRoute().Format());
				
				root.PointerSwipe(float2(100,100), float2(400,100));
				root.StepFrame(5);
				Assert.AreEqual( "one/one", p.R.GetCurrentRoute().Format());
				Assert.AreEqual(0, p.R.TestHistoryCount);
				
				root.PointerSwipe(float2(400,100), float2(100,100));
				root.StepFrame(5);
				Assert.AreEqual( "two?{}", p.R.GetCurrentRoute().Format());
				Assert.AreEqual(1, p.R.TestHistoryCount);
			}
		}
		
		[Test]
		//tests the Busy waiting mechanism used to defer page transitions
		public void DeferPageSwitch()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.DeferPageSwitch();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				Assert.AreEqual(p.one, p.Nav.Active);
				
				p.R.Push( new Route("two") );
				root.PumpDeferred();
				
				Assert.AreEqual(p.one, p.Nav.Active); //this need not be guaranteed I think
				Assert.AreEqual(1,TriggerProgress(p.T)); //though this must be
				Assert.AreEqual(TriggerPlayState.Stopped, p.T.PlayState);
				root.StepFrame(0.1f);
				
				Assert.AreEqual(1,TriggerProgress(p.T));
				p.B.IsBusy = false;
				root.PumpDeferred();
				Assert.AreEqual(p.two, p.Nav.Active);
				Assert.AreEqual(TriggerPlayState.Backward, p.T.PlayState);
				
				root.StepFrame(0.5f);
				Assert.AreEqual(0.5f,TriggerProgress(p.T));
			}
		}
		
		[Test]
		//ensures a busy deferred page transition is forced if a new route request comes in
		public void ForceDefer()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.ForceDefer();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				p.R.Push( new Route("two") );
				p.R.Push( new Route("three") );
				root.StepFrameJS();
				Assert.AreEqual("yes", p.one.Title);
				//there's no guarantee of Activate/Deactived being called anymore in this situation.
				//we don't have a good way to test the forced change
				//Assert.AreEqual("yes", p.two.Title);
				Assert.AreEqual("yes", p.three.Title);
			}
		}
		
		[Test]
		//checks some cleanup and caching conditions in the navigator
		public void PreparedCleanup()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.PreparedCleanup();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				var p1 = p.Nav.Active;
				
				//use internal interface for simplicity/directness in test.
				p.R.Modify( ModifyRouteHow.PreparePush, 
					new Route( "one", "1" ), NavigationGotoMode.Transition, "" );
				p.R.PrepareProgress = 0.5;
				p.R.Modify( ModifyRouteHow.FinishPrepared, null, NavigationGotoMode.Transition, "" );
				root.PumpDeferred();
				
				var p2 = p.Nav.Active;
				Assert.IsFalse( p1 == p2 );
				Assert.AreEqual( "1", p2.Parameter );

				p.R.Modify( ModifyRouteHow.PreparePush, 
					new Route( "one", "2" ), NavigationGotoMode.Transition, "" );
				p.R.PrepareProgress = 0.5;
				p.R.Modify( ModifyRouteHow.FinishPrepared, null, NavigationGotoMode.Transition, "" );
				root.PumpDeferred();
				
				var p3 = p.Nav.Active;
				Assert.IsFalse(p2 == p3); //first fix ensured only this bit...
				Assert.IsTrue( p1 == p3 ); //not this
				Assert.AreEqual( "2", p3.Parameter );
			}
		}
		
		[Test]
		//checks the removing items aren't transition triggered as well
		public void Removing()
		{
			Router.TestClearMasterRoute();
			var p = new UX.Navigator.Removing();
			using (var root = TestRootPanel.CreateWithChild(p))
			{
				var p1 = p.Nav.Active as NRPage;
				
				p.R.Goto( new Route( "one", "1" ) );
				root.StepFrame(); //extra for RemovingAnimation
				root.StepFrame(0.5f);
				Assert.AreEqual(0.5f, TriggerProgress(p1.T2));
				Assert.AreEqual(0, TriggerProgress(p1.T1));
			}
		}
		
		List<T> GetChildren<T>(Visual n) where T : Node
		{
			var l = new List<T>();
			for (int i=0; i < n.Children.Count; ++i)
			{
				var m = n.Children[i] as T;
				if (m != null)
					l.Add(m);
			}
			return l;
		}
	}
}

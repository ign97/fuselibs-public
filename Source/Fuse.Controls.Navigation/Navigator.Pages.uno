using Fuse.Reactive;

using Fuse.Navigation;

namespace Fuse.Controls
{
	//TODO: Can probably be moved up to NavigationControl
	public partial class Navigator
	{
		//TODO: Change to IObservableArray
		IArray _pages;
		Uno.IDisposable _pagesSubscription;
		public IArray Pages
		{
			get { return _pages; }
			set
			{
				_pages = value;
				OnPagesChanged();
			}
		}
		
		void OnPagesChanged()
		{
			if (!IsRootingStarted)
				return;
				
			if (_pagesSubscription != null)
			{
				_pagesSubscription.Dispose();
				_pagesSubscription = null;
			}
			
			var obs = _pages as IObservable;
			if (obs != null)
				_pagesSubscription = obs.Subscribe(this);
			FullUpdatePages();
		}
		
		void FullUpdatePages()
		{
			string path = null, param = null;
			int pageNdx = _pages.Length - 1;
			if (pageNdx >= 0)
			{
				var obj = _pages[pageNdx] as IObject;
				if (obj != null && obj.ContainsKey("path"))
					path = Marshal.ToType<string>(obj["path"]);
			}
				
			var op = pageNdx > 0 ? RoutingOperation.Push : RoutingOperation.Goto;
			var trans = NavigationGotoMode.Transition;
			
			Visual v;
			(this as IRouterOutlet).Goto( ref path, ref param, trans, op, "", out v );
		}
		
		void IObserver.OnSet(object newValue)
		{
			FullUpdatePages();
		}
		
		void IObserver.OnFailed(string message)
		{
			FullUpdatePages();
		}
		
		void IObserver.OnAdd(object value)
		{
			FullUpdatePages();
		}
		
		void IObserver.OnRemoveAt(int index)
		{
			FullUpdatePages();
		}
		
		void IObserver.OnInsertAt(int index, object value)
		{
			FullUpdatePages();
		}
		
		void IObserver.OnNewAt(int index, object value)
		{
			FullUpdatePages();
		}
		
		void IObserver.OnNewAll(IArray values)
		{
			FullUpdatePages();
		}
		
		void IObserver.OnClear()
		{
			FullUpdatePages();
		}
	}
	
}
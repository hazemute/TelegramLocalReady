using System.Collections;
using System.Collections.Concurrent;

namespace MyTelegram.Services.Services;

public class CacheHelper<TKey, TValue> : ICacheHelper<TKey, TValue> where TKey : notnull
{
    private readonly ConcurrentDictionary<TKey, TValue> _caches = new();
    public bool TryAdd(TKey key, TValue value)
    {
        return _caches.TryAdd(key, value);
    }

    public bool TryGetValue(TKey key, out TValue? value)
    {
        return _caches.TryGetValue(key, out value);
    }

    public bool TryRemove(TKey key, out TValue? value)
    {
        return _caches.TryRemove(key, out value);
    }
}

public class MyCircularBuffer<T> : IEnumerable<T>
{
    private readonly T[] _buffer;
    private int _start;
    private int _end;

    public int Capacity => _buffer.Length - 1;

    public MyCircularBuffer(int capacity)
    {
        if (capacity <= 0) throw new ArgumentException(nameof(capacity));

        _buffer = new T[capacity + 1];
        _start = 0;
        _end = 0;
    }

    public MyCircularBuffer(int capacity, params T[] items)
        : this(capacity)
    {
        if (items.Length > capacity) throw new ArgumentException(nameof(capacity));

        foreach (var item in items)
        {
            Put(item);
        }
    }

    public T GetFirstItem()
    {
        return _buffer[0];
    }

    public void Put(T item)
    {
        _buffer[_end] = item;
        _end = (_end + 1) % _buffer.Length;
        if (_end == _start)
        {
            _start = (_start + 1) % _buffer.Length;
        }
    }

    public IEnumerator<T> GetEnumerator()
    {
        var i = _start;
        while (i != _end)
        {
            yield return _buffer[i];
            i = (i + 1) % _buffer.Length;
        }
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }
}
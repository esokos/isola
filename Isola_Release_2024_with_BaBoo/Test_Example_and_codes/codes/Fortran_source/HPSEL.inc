      SUBROUTINE hpsel(m,n,arr,heap)
      INTEGER m,n
      REAL arr(n),heap(m)
CU    USES sort
      INTEGER i,j,k
      REAL swap
      if (m.gt.n/2.or.m.lt.1) pause 'probable misuse of hpsel'
      do 11 i=1,m
        heap(i)=arr(i)
11    continue
      call sort(m,heap)
      do 12 i=m+1,n
        if(arr(i).gt.heap(1))then
          heap(1)=arr(i)
          j=1
1         continue
            k=2*j
            if(k.gt.m)goto 2
            if(k.ne.m)then
              if(heap(k).gt.heap(k+1))k=k+1
            endif
            if(heap(j).le.heap(k))goto 2
            swap=heap(k)
            heap(k)=heap(j)
            heap(j)=swap
            j=k
          goto 1
2         continue
        endif
12    continue
      return
      end

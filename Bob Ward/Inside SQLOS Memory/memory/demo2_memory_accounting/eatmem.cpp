// eatmem.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <Windows.h>

#define DEFAULT_MAX 65536 // Default is 64Kb if we can't tell from system
#define DEFAULT_BLOCK 65536 // Default is 64Kb to commit each block if we can't get from system
#define WINDOWS_MAX (1024i64*1024i64*1024i64*1024i64)*8i64 // 8TB max for Windows 2012. We can go to 128TB for 8.1 and later but I don't feel like checking os versions

int _tmain(int argc, _TCHAR* argv[])
{
	// need this for cout
	using namespace std;

	int iret = 0;
	INT64 iNumBytesToCommit = DEFAULT_MAX;
	INT64 iCommitSize = DEFAULT_BLOCK; 
	INT64 iBytesCommitted = 0;
	LPVOID resptr = NULL;
	LPVOID commitptr = NULL;
	BOOL bshouldcontinue = FALSE;
	INT64 counter = 0;
	SYSTEM_INFO sysinfo;
	DWORD dwAllocationGranularity = DEFAULT_BLOCK; // Set to 64Kb in case we can't get from system

	// Get the allocation granularity for VirtualAlloc
	GetSystemInfo(&sysinfo);
	if (!GetLastError())
	{
		// Use the system's default granularity.
		dwAllocationGranularity = sysinfo.dwAllocationGranularity;
	}

	// 2nd optional argument is max size to commit
	if (argc > 1)
	{
		iNumBytesToCommit = _tstoi64((_TCHAR *)argv[1]);
		// Let's sanity check the input
		if (iNumBytesToCommit < dwAllocationGranularity)
		{
			cout << "Upgrading max commit to min allocation size " << dwAllocationGranularity << endl;
			iNumBytesToCommit = dwAllocationGranularity;
		}
		else if (iNumBytesToCommit > WINDOWS_MAX)
		{
			cout << "Downgrading max commit to Windows limit " << WINDOWS_MAX << endl;
			iNumBytesToCommit = WINDOWS_MAX;
		}
		else if (iNumBytesToCommit % dwAllocationGranularity)
		{
			iNumBytesToCommit -= (iNumBytesToCommit % dwAllocationGranularity);
			cout << "Rounding down max commit to an allocation boundary " << iNumBytesToCommit << endl;
		} 
		// else we are within min and max and are aligned on alloc boundary

		// 3rd optional argument is commit block size with a default of 64Kb
		if (argc > 2)
		{
			// Let's sanity check the input
			iCommitSize = _tstoi64((_TCHAR *)argv[2]);
			if (iCommitSize < dwAllocationGranularity) // You picked too small a block size
			{
				cout << "Upgrading block commit size to min allocation size " << dwAllocationGranularity << endl;
				iCommitSize = dwAllocationGranularity;
			}
			else if (iCommitSize > iNumBytesToCommit) // You tried to pick a block size bigger than max commit
			{	
				cout << "You picked a block commit size bigger than max commit. Downgrading block size to max commit " << iNumBytesToCommit << endl;
				iCommitSize = iNumBytesToCommit;
			}
			else if (iCommitSize % dwAllocationGranularity)
			{
				iCommitSize -= (iCommitSize % dwAllocationGranularity);
				cout << "Rounding down block commit size to an allocation boundary " << iCommitSize << endl;
			} 
			// else block commit size is > alloc boundary <= max commit and on alloc boundary
		}
	}
	
	cout << "Running with max commit of " << iNumBytesToCommit << " and block commit size of " << iCommitSize << endl;

	// Reserve a massive amount up front and commit from that
	resptr = VirtualAlloc(NULL, iNumBytesToCommit, MEM_RESERVE, PAGE_READWRITE);
	if (resptr)
	{
		while ((iBytesCommitted < iNumBytesToCommit) && (!iret))
		{
			// If iCommitSize will spill us over change it to get last remaining memory to max
			// We should at this point count remaining bytes and leave at next loop iteration
			if ((iBytesCommitted+iCommitSize) > iNumBytesToCommit)
					iCommitSize = iNumBytesToCommit-iBytesCommitted;
			commitptr = VirtualAlloc((BYTE *)resptr+iBytesCommitted, iCommitSize, MEM_COMMIT, PAGE_READWRITE);
			iret = GetLastError();
			if ((commitptr) && (!iret))
			{
				// Touch ptr to get into working set
				SecureZeroMemory(commitptr, iCommitSize);
				iBytesCommitted += iCommitSize;
			}
			else
			{
				cout << endl << "Failure allocating memory. OS Error: " << iret << endl;
				break; // Failure
			}

			// Write out a progress indicator every 10000 loops in case there is alot to alloc.
			// Otherwise it is typically finishes so fast you don't need progress indicator
			if (!((counter++) % 10000i64))
				cout << ".";
		} // end while loop
	}
	else
	{
		iret = GetLastError();
		cout << "Failure to reserve memory from VirtualAlloc. OS Error = " << iret << endl;
	}
	cout << endl;
	
	cout << "=============================================" << endl;
	cout << "Bytes reserved = " << iNumBytesToCommit << endl;
	cout << "Bytes committed = " << iBytesCommitted << endl;
	cout << "Last error = " << iret << endl;
	cout << "=============================================" << endl;
	cout << endl;
	cout << "Press a key and hit return to terminate: ";
	cin >> bshouldcontinue;

	return 0;
}


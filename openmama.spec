%define MAMA   https://github.com/OpenMAMA/OpenMAMA.git
%define DATA   https://github.com/OpenMAMA/OpenMAMA-testdata.git 
%define	ZMQ    https://github.com/fquinner/OpenMAMA-zmq.git

%define BUILD_VERSION 2.4.1
%define BUILD_NUMBER 2

Summary: An abstraction layer which sits on top of multiple message oriented middlewares
Name:       openmama
Version:    %{?BUILD_VERSION}
Release:    %{?BUILD_NUMBER}.td%{?dist}
License:    LGPLv2
URL:        http://www.openmama.org
Group:      Development/Libraries
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)



%define java_home /etc/alternatives/java_sdk

BuildRequires:  git-core gcc gcc-c++ make binutils libtool autoconf automake ant libuuid-devel flex doxygen scons java-devel qpid-proton-c-devel libevent-devel ncurses-devel libxml2-devel
Requires: libxml2 libuuid qpid-proton-c libevent ncurses


%description
OpenMAMA is a high performance abstraction layer for message oriented
middlewares, where MAMA stands for Middleware Agnostic Messaging API.

%package zmq
Group: Development/Libraries
Summary: ZeroMQ Middleware for OpenMAMA
Requires: openmama = %{BUILD_VERSION}
Requires: zeromq
BuildRequires: zeromq-devel

%description zmq
OpenMAMA ZeroMQ Middleware library based on %{ZMQ}

%package devel
Group: Development/Libraries
Summary: Developer Files for OpenMAMA
Requires: openmama = %{BUILD_VERSION}


%description devel
OpenMAMA Development Files

%prep
#Hint:No %setup section because we dont have %SOURCE, Sources will be downloaded

cd %{_builddir}
rm -Rf openmama zmq data
git clone %{MAMA} openmama
git clone %{ZMQ} zmq
git clone %{DATA} data

cd openmama
git checkout OpenMAMA-%{BUILD_VERSION}

%build
cd %{_builddir}/openmama
scons middleware=qpid product=mamdajni java_home=%{java_home} with_testtools=yes jobs=n
#  install to openmama_install_<Version>
cd ../zmq
scons --with-mamasource=%{_builddir}/openmama --with-mamainstall=%{_builddir}/openmama/openmama_install_%{BUILD_VERSION}

%install
# scons install
rm -rf %{buildroot}
mkdir -p %{buildroot}/opt/openmama/
mkdir %{buildroot}/opt/openmama/data
mkdir %{buildroot}/opt/openmama/config
cp -r %{_builddir}/openmama/openmama_install_*/* %{buildroot}/opt/openmama
cp %{_builddir}/openmama/README* %{buildroot}/opt/openmama/
cp %{_builddir}/openmama/COPYING %{buildroot}/opt/openmama/
cp %{_builddir}/openmama/mama/c_cpp/src/examples/mama.properties %{buildroot}/opt/openmama/config
cp -p %{_builddir}/zmq/libmamazmqimpl.* %{buildroot}/opt/openmama/lib/ 
cp -p %{_builddir}/zmq/config/mama.properties %{buildroot}/opt/openmama/config/mama-zmq.properties
cp -rp %{_builddir}/data/* %{buildroot}/opt/openmama/data/
cp -p %{_builddir}/data/profiles/profile.openmama %{buildroot}/opt/openmama/config/

%clean
rm -rf %{buildroot}

%post
if [ $1 -eq 1 ] ; then #1=install,2=upgrade
	ln -s /opt/openmama/config/profile.openmama /etc/profile.d/openmama.sh
fi

%postun
if [ $1 -eq 0 ] ; then #0=uninstall
	rm /etc/profile.d/openmama.sh
fi

%files
%defattr(-,root,root,-)
/opt/openmama/bin/*
%exclude /opt/openmama/lib/*.a
%exclude /opt/openmama/lib/libmamazmqimpl*
%exclude /opt/openmama/config/mama-zmq.properties
/opt/openmama/lib/*
/opt/openmama/config/*
/opt/openmama/data/*
/opt/openmama/README*
/opt/openmama/COPYING

%files zmq
/opt/openmama/config/mama-zmq.properties
/opt/openmama/lib/*zmq*

%files devel
/opt/openmama/lib/*.a
/opt/openmama/include
/opt/openmama/examples

%changelog

* Fri Sep 02 2016 Thomas Dressler  - 2.4.1-2
--Clone from GitHub and build
--Split into main and devel package
- Add fquinner/OpenMAMA-zmq build

* Fri Aug 26 2016 Thomas Dressler  - 2.4.1-1
- adopted from https://github.com/OpenMAMA/OpenMAMA/releases/tag/OpenMAMA-2.4.1-release

* Thu Apr 14 2016 Thomas Dressler  - 2.4.0-1
- adopted from http://www.openmama.org/downloads/releases

* Sun Nov 15 2015 Thomas Dressler  - 2.3.3-1
- adopted from http://www.openmama.org/downloads/releases
- add link to profile and %post sections 

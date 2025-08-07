/****************************************************************************
** Meta object code from reading C++ file 'settings.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.4.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../src/app/settings.h"
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'settings.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.4.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
namespace {
struct qt_meta_stringdata_Settings_t {
    uint offsetsAndSizes[24];
    char stringdata0[9];
    char stringdata1[17];
    char stringdata2[1];
    char stringdata3[19];
    char stringdata4[18];
    char stringdata5[16];
    char stringdata6[23];
    char stringdata7[10];
    char stringdata8[12];
    char stringdata9[11];
    char stringdata10[9];
    char stringdata11[16];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_Settings_t::offsetsAndSizes) + ofs), len
Q_CONSTINIT static const qt_meta_stringdata_Settings_t qt_meta_stringdata_Settings = {
    {
        QT_MOC_LITERAL(0, 8),  // "Settings"
        QT_MOC_LITERAL(9, 16),  // "ollamaUrlChanged"
        QT_MOC_LITERAL(26, 0),  // ""
        QT_MOC_LITERAL(27, 18),  // "ollamaModelChanged"
        QT_MOC_LITERAL(46, 17),  // "fontFamilyChanged"
        QT_MOC_LITERAL(64, 15),  // "fontSizeChanged"
        QT_MOC_LITERAL(80, 22),  // "availableModelsChanged"
        QT_MOC_LITERAL(103, 9),  // "ollamaUrl"
        QT_MOC_LITERAL(113, 11),  // "ollamaModel"
        QT_MOC_LITERAL(125, 10),  // "fontFamily"
        QT_MOC_LITERAL(136, 8),  // "fontSize"
        QT_MOC_LITERAL(145, 15)   // "availableModels"
    },
    "Settings",
    "ollamaUrlChanged",
    "",
    "ollamaModelChanged",
    "fontFamilyChanged",
    "fontSizeChanged",
    "availableModelsChanged",
    "ollamaUrl",
    "ollamaModel",
    "fontFamily",
    "fontSize",
    "availableModels"
};
#undef QT_MOC_LITERAL
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_Settings[] = {

 // content:
      10,       // revision
       0,       // classname
       0,    0, // classinfo
       5,   14, // methods
       5,   49, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       5,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,   44,    2, 0x06,    6 /* Public */,
       3,    0,   45,    2, 0x06,    7 /* Public */,
       4,    0,   46,    2, 0x06,    8 /* Public */,
       5,    0,   47,    2, 0x06,    9 /* Public */,
       6,    0,   48,    2, 0x06,   10 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // properties: name, type, flags
       7, QMetaType::QString, 0x00015103, uint(0), 0,
       8, QMetaType::QString, 0x00015103, uint(1), 0,
       9, QMetaType::QString, 0x00015103, uint(2), 0,
      10, QMetaType::Int, 0x00015103, uint(3), 0,
      11, QMetaType::QStringList, 0x00015103, uint(4), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject Settings::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_Settings.offsetsAndSizes,
    qt_meta_data_Settings,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_Settings_t,
        // property 'ollamaUrl'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'ollamaModel'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'fontFamily'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'fontSize'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'availableModels'
        QtPrivate::TypeAndForceComplete<QStringList, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<Settings, std::true_type>,
        // method 'ollamaUrlChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'ollamaModelChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'fontFamilyChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'fontSizeChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'availableModelsChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>
    >,
    nullptr
} };

void Settings::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<Settings *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->ollamaUrlChanged(); break;
        case 1: _t->ollamaModelChanged(); break;
        case 2: _t->fontFamilyChanged(); break;
        case 3: _t->fontSizeChanged(); break;
        case 4: _t->availableModelsChanged(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (Settings::*)();
            if (_t _q_method = &Settings::ollamaUrlChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (Settings::*)();
            if (_t _q_method = &Settings::ollamaModelChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (Settings::*)();
            if (_t _q_method = &Settings::fontFamilyChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (Settings::*)();
            if (_t _q_method = &Settings::fontSizeChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 3;
                return;
            }
        }
        {
            using _t = void (Settings::*)();
            if (_t _q_method = &Settings::availableModelsChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 4;
                return;
            }
        }
    }else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<Settings *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QString*>(_v) = _t->ollamaUrl(); break;
        case 1: *reinterpret_cast< QString*>(_v) = _t->ollamaModel(); break;
        case 2: *reinterpret_cast< QString*>(_v) = _t->fontFamily(); break;
        case 3: *reinterpret_cast< int*>(_v) = _t->fontSize(); break;
        case 4: *reinterpret_cast< QStringList*>(_v) = _t->availableModels(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<Settings *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setOllamaUrl(*reinterpret_cast< QString*>(_v)); break;
        case 1: _t->setOllamaModel(*reinterpret_cast< QString*>(_v)); break;
        case 2: _t->setFontFamily(*reinterpret_cast< QString*>(_v)); break;
        case 3: _t->setFontSize(*reinterpret_cast< int*>(_v)); break;
        case 4: _t->setAvailableModels(*reinterpret_cast< QStringList*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
    (void)_a;
}

const QMetaObject *Settings::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Settings::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_Settings.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int Settings::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 5)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 5;
    }else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    }
    return _id;
}

// SIGNAL 0
void Settings::ollamaUrlChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void Settings::ollamaModelChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void Settings::fontFamilyChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void Settings::fontSizeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void Settings::availableModelsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE

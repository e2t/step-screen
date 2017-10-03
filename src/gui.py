# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'gui.ui'
#
# Created by: PyQt5 UI code generator 5.9
#
# WARNING! All changes made in this file will be lost!

from PyQt5 import QtCore, QtGui, QtWidgets

class Ui_Dialog(object):
    def setupUi(self, Dialog):
        Dialog.setObjectName("Dialog")
        Dialog.resize(798, 426)
        self.formLayout = QtWidgets.QFormLayout(Dialog)
        self.formLayout.setObjectName("formLayout")
        self.horizontalLayout = QtWidgets.QHBoxLayout()
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.verticalLayout = QtWidgets.QVBoxLayout()
        self.verticalLayout.setObjectName("verticalLayout")
        self.gridLayout = QtWidgets.QGridLayout()
        self.gridLayout.setObjectName("gridLayout")
        self.label = QtWidgets.QLabel(Dialog)
        self.label.setObjectName("label")
        self.gridLayout.addWidget(self.label, 0, 0, 1, 1)
        self.label_4 = QtWidgets.QLabel(Dialog)
        self.label_4.setObjectName("label_4")
        self.gridLayout.addWidget(self.label_4, 3, 0, 1, 1)
        self.label_3 = QtWidgets.QLabel(Dialog)
        self.label_3.setObjectName("label_3")
        self.gridLayout.addWidget(self.label_3, 2, 0, 1, 1)
        self.label_2 = QtWidgets.QLabel(Dialog)
        self.label_2.setObjectName("label_2")
        self.gridLayout.addWidget(self.label_2, 1, 0, 1, 1)
        self.cmb_gap = QtWidgets.QComboBox(Dialog)
        self.cmb_gap.setObjectName("cmb_gap")
        self.gridLayout.addWidget(self.cmb_gap, 1, 1, 1, 1)
        self.edt_depth_channel = QtWidgets.QLineEdit(Dialog)
        self.edt_depth_channel.setObjectName("edt_depth_channel")
        self.gridLayout.addWidget(self.edt_depth_channel, 3, 1, 1, 1)
        self.cmb_thickness = QtWidgets.QComboBox(Dialog)
        self.cmb_thickness.setObjectName("cmb_thickness")
        self.gridLayout.addWidget(self.cmb_thickness, 2, 1, 1, 1)
        self.horizontalLayout_2 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_2.setObjectName("horizontalLayout_2")
        self.cmb_width_size = QtWidgets.QComboBox(Dialog)
        self.cmb_width_size.setObjectName("cmb_width_size")
        self.horizontalLayout_2.addWidget(self.cmb_width_size)
        self.cmb_height_size = QtWidgets.QComboBox(Dialog)
        self.cmb_height_size.setObjectName("cmb_height_size")
        self.horizontalLayout_2.addWidget(self.cmb_height_size)
        self.gridLayout.addLayout(self.horizontalLayout_2, 0, 1, 1, 1)
        self.verticalLayout.addLayout(self.gridLayout)
        spacerItem = QtWidgets.QSpacerItem(20, 40, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        self.verticalLayout.addItem(spacerItem)
        self.horizontalLayout_3 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_3.setObjectName("horizontalLayout_3")
        spacerItem1 = QtWidgets.QSpacerItem(40, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum)
        self.horizontalLayout_3.addItem(spacerItem1)
        self.btn_run = QtWidgets.QPushButton(Dialog)
        self.btn_run.setObjectName("btn_run")
        self.horizontalLayout_3.addWidget(self.btn_run)
        self.verticalLayout.addLayout(self.horizontalLayout_3)
        self.horizontalLayout.addLayout(self.verticalLayout)
        self.edt_results = QtWidgets.QPlainTextEdit(Dialog)
        self.edt_results.setReadOnly(True)
        self.edt_results.setObjectName("edt_results")
        self.horizontalLayout.addWidget(self.edt_results)
        self.formLayout.setLayout(0, QtWidgets.QFormLayout.LabelRole, self.horizontalLayout)

        self.retranslateUi(Dialog)
        QtCore.QMetaObject.connectSlotsByName(Dialog)

    def retranslateUi(self, Dialog):
        _translate = QtCore.QCoreApplication.translate
        self.label.setText(_translate("Dialog", "Типоразмер"))
        self.label_4.setText(_translate("Dialog", "Глубина канала, мм"))
        self.label_3.setText(_translate("Dialog", "Толщина ламелей, мм"))
        self.label_2.setText(_translate("Dialog", "Прозор, мм"))
        self.btn_run.setText(_translate("Dialog", "Выполнить"))


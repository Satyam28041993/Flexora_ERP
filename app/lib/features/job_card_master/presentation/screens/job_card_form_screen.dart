import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer_master/data/models/customer_model.dart';
import '../../../customer_master/logic/customer_providers.dart';
import '../../../product_master/data/models/product_model.dart';
import '../../../product_master/logic/product_providers.dart';
import '../../../tooling_master/data/models/die_model.dart';
import '../../../tooling_master/data/models/plate_model.dart';
import '../../../tooling_master/logic/tooling_providers.dart';
import '../../data/models/job_card_model.dart';
import '../../logic/job_card_providers.dart';
import '../../logic/job_sheet_pdf_generator.dart';
import '../../../order_intake/data/models/order_model.dart';
import '../../../order_intake/logic/order_providers.dart';
import '../widgets/job_card_attachments_widget.dart';
import '../widgets/roll_winding_diagram_widget.dart';

class JobCardFormScreen extends ConsumerStatefulWidget {
  const JobCardFormScreen({super.key, this.jobCard});

  final JobCardModel? jobCard;

  @override
  ConsumerState<JobCardFormScreen> createState() => _JobCardFormScreenState();
}

class _JobCardFormScreenState extends ConsumerState<JobCardFormScreen> {
  final _formKey = GlobalKey<FormState>();

  CustomerModel? _selectedCustomer;
  ProductModel? _selectedProduct;
  PlateModel? _selectedPlate;
  DieModel? _selectedDie;
  OrderModel? _selectedPO;

  late TextEditingController _jobCardNoController;
  late TextEditingController _dateStrController;
  late TextEditingController _machineNameController;
  late TextEditingController _poNumberController;
  late TextEditingController _poDateStrController;
  late TextEditingController _jobCodeController;
  late TextEditingController _cqalNoController;
  late TextEditingController _customerNameController;
  late TextEditingController _jobNameController;
  late TextEditingController _labelSizeController;
  late TextEditingController _labelPerMtrController;
  late TextEditingController _stockLabelQtyController;
  late TextEditingController _artWorkNoController;
  late TextEditingController _gearSizeController;
  late TextEditingController _noOfColorsController;
  late TextEditingController _specialColorsController;
  late TextEditingController _materialAndCodeController;
  late TextEditingController _productMaterialTypeController;
  late TextEditingController _uvGlossLaminationController;
  late TextEditingController _targetQtyController;
  late TextEditingController _plannedQtyController;
  late TextEditingController _paperSizeController;
  late TextEditingController _upsController;
  late TextEditingController _rmtController;
  late TextEditingController _remarksController;

  String _rollWindingDirection = 'F4';
  String _numbering = 'No';
  String _punchOnline = 'No';
  String _punchType = 'ONLINE';
  String _specialInfo = 'No';
  String _plateOldNew = 'NEW';
  String _reslamDelam = 'No';
  String _asPerShadeCard = 'Yes';
  String _uvMat = 'No';
  String _textureVarnish = 'No';
  String _screenDetails = 'No';
  String _stampingDetails = 'No';

  bool _isSaving = false;
  bool _isLoadingAutoNum = false;

  @override
  void initState() {
    super.initState();
    final j = widget.jobCard;
    final nowFormatted = DateFormat('dd-MM-yyyy').format(DateTime.now());

    _jobCardNoController = TextEditingController(text: j?.jobCardNo ?? '');
    _dateStrController = TextEditingController(text: j?.dateStr.isNotEmpty == true ? j!.dateStr : nowFormatted);
    _machineNameController = TextEditingController(text: j?.machineName ?? 'LOMBARDI 430');
    _poNumberController = TextEditingController(text: j?.poNumber ?? '');
    _poDateStrController = TextEditingController(text: j?.poDateStr ?? nowFormatted);
    _jobCodeController = TextEditingController(text: j?.jobCode ?? '208280');
    _cqalNoController = TextEditingController(text: j?.cqalNo ?? '');
    _customerNameController = TextEditingController(text: j?.customerName ?? 'RALLIS INDIA LIMITED');
    _jobNameController = TextEditingController(text: j?.productName ?? 'DAZOL TEBU 430 SC 1 LTR EXP');
    _labelSizeController = TextEditingController(text: j?.labelSize ?? '280 X 143');
    _labelPerMtrController = TextEditingController(text: j?.labelPerMtr.toString() ?? '3.53');
    _stockLabelQtyController = TextEditingController(text: j?.stockLabelQty.toString() ?? '');
    _artWorkNoController = TextEditingController(text: j?.artWorkNo ?? '');
    _gearSizeController = TextEditingController(text: j?.gearSize ?? '89');
    _noOfColorsController = TextEditingController(text: j?.noOfColors ?? 'CMYK');
    _specialColorsController = TextEditingController(text: j?.specialColors ?? 'P 353 C / P 2727 C');
    _materialAndCodeController = TextEditingController(text: j?.materialAndCode ?? 'AVERY');
    _productMaterialTypeController = TextEditingController(text: j?.productMaterialType ?? 'C-MIRRORCOAT');
    _uvGlossLaminationController = TextEditingController(text: j?.uvGlossLamination ?? 'VARNISH');
    _targetQtyController = TextEditingController(text: j?.targetOrderQty.toString() ?? '22900');
    _plannedQtyController = TextEditingController(text: j?.plannedProductionQty.toString() ?? '23500');
    _paperSizeController = TextEditingController(text: j?.paperSize.toString() ?? '160');
    _upsController = TextEditingController(text: j?.ups.toString() ?? '1');
    _rmtController = TextEditingController(text: j?.rmt.toString() ?? '6483');
    _remarksController = TextEditingController(text: j?.remarks ?? '');

    if (j != null) {
      _rollWindingDirection = j.rollWindingDirection;
      _numbering = j.numbering;
      _punchOnline = j.punchOnline;
      _punchType = j.punchType;
      _specialInfo = j.specialInfo;
      _plateOldNew = j.plateOldNew;
      _reslamDelam = j.reslamDelam;
      _asPerShadeCard = j.asPerShadeCard;
      _uvMat = j.uvMat;
      _textureVarnish = j.textureVarnish;
      _screenDetails = j.screenDetails;
      _stampingDetails = j.stampingDetails;
    } else {
      _fetchNextJobCardNumber();
    }
  }

  Future<void> _fetchNextJobCardNumber() async {
    setState(() => _isLoadingAutoNum = true);
    try {
      final repo = ref.read(jobCardRepositoryProvider);
      final nextNum = await repo.getNextJobCardNumber();
      if (mounted) {
        setState(() {
          _jobCardNoController.text = nextNum;
          _isLoadingAutoNum = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAutoNum = false);
    }
  }

  void _recalculateRMT() {
    final orderQty = double.tryParse(_targetQtyController.text) ?? 0.0;
    final labelPerMtr = double.tryParse(_labelPerMtrController.text) ?? 1.0;
    final ups = int.tryParse(_upsController.text) ?? 1;

    if (labelPerMtr > 0 && ups > 0) {
      final calculatedRmt = (orderQty / (labelPerMtr * ups)).roundToDouble();
      _rmtController.text = calculatedRmt.toStringAsFixed(0);
    }
  }

  List<OrderModel> _getAvailableOpenOrders(List<OrderModel> firestoreOrders) {
    List<OrderModel> source = firestoreOrders;
    if (source.isEmpty) {
      source = [
        OrderModel(
          id: 'sample-po-1',
          plantId: DefaultPlant.id,
          poNumber: 'PK/MUM/155/2026-2027',
          poDate: DateTime(2026, 8, 5),
          customerId: 'cust-rallis',
          customerName: 'RALLIS INDIA LIMITED',
          customerGstNo: '27AAACR1234A1Z5',
          shippingAddress: 'Plot 45, MIDC Industrial Estate, Mumbai',
          taxableSubtotal: 124805,
          grandTotalAmount: 147269,
          createdAt: DateTime.now(),
          createdBy: 'system',
          lineItems: const [
            OrderLineItemModel(
              id: 'li-1',
              itemNo: 1,
              itemName: 'PANIDA 1 LTR (NB) (PG/SKU/001)',
              quantityPcs: 22900,
              unitRateRs: 5.45,
              lineAmountRs: 124805,
              sizeWidthMm: 280,
              sizeHeightMm: 143,
            ),
          ],
        ),
        OrderModel(
          id: 'sample-po-2',
          plantId: DefaultPlant.id,
          poNumber: 'BM/PGPL/26-27/051',
          poDate: DateTime(2026, 8, 2),
          customerId: 'cust-bayer',
          customerName: 'BAYER CROP SCIENCE LTD',
          customerGstNo: '27AAACB5678B1Z2',
          shippingAddress: 'Plot 12, GIDC, Vapi',
          taxableSubtotal: 63000,
          grandTotalAmount: 74340,
          createdAt: DateTime.now(),
          createdBy: 'system',
          lineItems: const [
            OrderLineItemModel(
              id: 'li-2',
              itemNo: 1,
              itemName: 'DECIS 250 ML LABEL',
              quantityPcs: 15000,
              unitRateRs: 4.20,
              lineAmountRs: 63000,
              sizeWidthMm: 210,
              sizeHeightMm: 120,
            ),
          ],
        ),
        OrderModel(
          id: 'sample-po-3',
          plantId: DefaultPlant.id,
          poNumber: 'PO:05051',
          poDate: DateTime(2026, 7, 28),
          customerId: 'cust-coromandel',
          customerName: 'COROMANDEL INTERNATIONAL',
          customerGstNo: '27AAACC9012C1Z9',
          shippingAddress: 'Industrial Area, Vadodara',
          taxableSubtotal: 190000,
          grandTotalAmount: 224200,
          createdAt: DateTime.now(),
          createdBy: 'system',
          lineItems: const [
            OrderLineItemModel(
              id: 'li-3',
              itemNo: 1,
              itemName: 'GROPLUS 5KG BAG STICKER',
              quantityPcs: 50000,
              unitRateRs: 3.80,
              lineAmountRs: 190000,
              sizeWidthMm: 300,
              sizeHeightMm: 180,
            ),
          ],
        ),
      ];
    }

    final openOrders = source.where((o) => o.status != 'Completed' && o.status != 'Cancelled').toList();

    if (_selectedCustomer != null) {
      final custName = _selectedCustomer!.companyName.toLowerCase().trim();
      final filteredByCust = openOrders.where((o) {
        return o.customerId == _selectedCustomer!.id ||
            o.customerName.toLowerCase().trim() == custName ||
            o.customerName.toLowerCase().contains(custName) ||
            custName.contains(o.customerName.toLowerCase().trim());
      }).toList();

      if (filteredByCust.isNotEmpty) return filteredByCust;
    }

    return openOrders;
  }

  List<ProductModel> _getAvailableProductsForPO(List<ProductModel> customerProducts) {
    if (_selectedPO != null && _selectedPO!.lineItems.isNotEmpty) {
      final List<ProductModel> result = [];

      for (final line in _selectedPO!.lineItems) {
        final match = customerProducts.where((p) {
          return p.productName.toLowerCase().trim() == line.itemName.toLowerCase().trim() ||
              (p.internalSkuCode.isNotEmpty && (p.internalSkuCode == line.ourSkuCode || p.internalSkuCode == line.customerSkuCode));
        }).firstOrNull;

        if (match != null) {
          if (!result.contains(match)) result.add(match);
        } else {
          final width = line.sizeWidthMm > 0 ? line.sizeWidthMm : 292.0;
          final height = line.sizeHeightMm > 0 ? line.sizeHeightMm : 137.0;
          final dynamicProduct = ProductModel(
            id: 'po-sku-${line.id}',
            plantId: DefaultPlant.id,
            internalSkuCode: line.ourSkuCode.isNotEmpty ? line.ourSkuCode : (line.customerSkuCode.isNotEmpty ? line.customerSkuCode : '208280'),
            customerId: _selectedPO!.customerId,
            customerName: _selectedPO!.customerName,
            customerProductCode: line.customerSkuCode.isNotEmpty ? line.customerSkuCode : 'PG/SKU/001',
            productName: line.itemName.isNotEmpty ? line.itemName : 'PANIDA 1 LTR (NB)',
            labelSpec: LabelSpecModel(
              widthMm: width,
              heightMm: height,
              substrateMaterial: line.substrateSpec.isNotEmpty ? line.substrateSpec : 'C-MIRRORCOAT',
              faceMaterial: 'AVERY',
            ),
            printSpec: const PrintSpecModel(
              colorCount: 4,
              pantoneCodes: 'P 353 C / P 2727 C',
              varnishType: 'VARNISH',
            ),
            machineSpec: MachineSpecModel(
              webWidthMm: 160.0,
              repeatCylinderMm: (height + 3.0) * 2.0,
              webUps: 1,
              repeatUps: 1,
              windingDirection: 'F4',
            ),
            createdAt: DateTime.now(),
            createdBy: 'system',
          );
          result.add(dynamicProduct);
        }
      }

      for (final p in customerProducts) {
        if (!result.any((item) => item.id == p.id || item.productName == p.productName)) {
          result.add(p);
        }
      }

      return result;
    }

    if (customerProducts.isNotEmpty) return customerProducts;

    return _getMockDefaultProducts();
  }

  List<ProductModel> _getMockDefaultProducts() {
    return [
      ProductModel(
        id: 'mock-p1',
        plantId: DefaultPlant.id,
        internalSkuCode: '208280',
        customerId: 'cust-rallis',
        customerName: 'Rallis India',
        customerProductCode: 'PG/SKU/001',
        productName: 'PANIDA 1 LTR (NB)',
        labelSpec: const LabelSpecModel(
          widthMm: 292.0,
          heightMm: 137.0,
          substrateMaterial: 'C-MIRRORCOAT',
          faceMaterial: 'AVERY',
        ),
        printSpec: const PrintSpecModel(
          colorCount: 4,
          pantoneCodes: 'P 353 C / P 2727 C',
          varnishType: 'VARNISH',
        ),
        machineSpec: const MachineSpecModel(
          webWidthMm: 160.0,
          repeatCylinderMm: 283.0,
          webUps: 1,
          repeatUps: 1,
          windingDirection: 'F4',
        ),
        createdAt: DateTime.now(),
        createdBy: 'system',
      ),
      ProductModel(
        id: 'mock-p2',
        plantId: DefaultPlant.id,
        internalSkuCode: '208281',
        customerId: 'cust-bayer',
        customerName: 'BAYER CROP SCIENCE LTD',
        customerProductCode: 'PG/SKU/002',
        productName: 'DECIS 250 ML LABEL',
        labelSpec: const LabelSpecModel(
          widthMm: 210.0,
          heightMm: 120.0,
          substrateMaterial: 'PP WHITE FILM',
          faceMaterial: 'FASSON FL201',
        ),
        printSpec: const PrintSpecModel(
          colorCount: 6,
          pantoneCodes: 'PANTONE 186 C / 021 C',
          varnishType: 'UV GLOSS VARNISH',
        ),
        machineSpec: const MachineSpecModel(
          webWidthMm: 220.0,
          repeatCylinderMm: 254.0,
          webUps: 2,
          repeatUps: 1,
          windingDirection: 'F2',
        ),
        createdAt: DateTime.now(),
        createdBy: 'system',
      ),
    ];
  }

  void _onPOSelected(OrderModel po, List<CustomerModel> customers, List<ProductModel> allProducts) {
    setState(() {
      _selectedPO = po;
      _poNumberController.text = po.poNumber;
      _poDateStrController.text = DateFormat('dd-MM-yyyy').format(po.poDate);

      // Auto-select Customer if matching customer found
      final matchCust = customers.where((c) =>
          c.id == po.customerId ||
          c.companyName.toLowerCase().trim() == po.customerName.toLowerCase().trim() ||
          po.customerName.toLowerCase().contains(c.companyName.toLowerCase())).firstOrNull;

      if (matchCust != null) {
        _selectedCustomer = matchCust;
        _customerNameController.text = matchCust.companyName;
      } else if (po.customerName.isNotEmpty) {
        _customerNameController.text = po.customerName;
      }

      // Auto-select first SKU from PO and auto-fill full manufacturing specs!
      final poProducts = _getAvailableProductsForPO(allProducts);
      if (poProducts.isNotEmpty) {
        _onSKUSelected(poProducts.first, isInitialPoSelection: true);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded Open PO [${po.poNumber}] for ${po.customerName}'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onSKUSelected(ProductModel product, {bool isInitialPoSelection = false}) {
    setState(() {
      _selectedProduct = product;
      _jobNameController.text = product.productName;
      _jobCodeController.text = product.internalSkuCode.isNotEmpty ? product.internalSkuCode : '208280';

      // 1. Label Size (Width X Height)
      final w = product.labelSpec.widthMm > 0 ? product.labelSpec.widthMm.toInt() : 292;
      final h = product.labelSpec.heightMm > 0 ? product.labelSpec.heightMm.toInt() : 137;
      _labelSizeController.text = '$w X $h';

      // 2. Gear Size (Teeth Z Count) & Cylinder Repeat Calculation
      final gearTeeth = product.machineSpec.gearTeethCount > 0
          ? product.machineSpec.gearTeethCount
          : (product.machineSpec.repeatCylinderMm > 0 ? (product.machineSpec.repeatCylinderMm / 3.175).round() : 89);
      _gearSizeController.text = gearTeeth.toString();

      final repeatMm = gearTeeth * 3.175;

      // 3. Label per Meter (Impressions / Meters) Calculation
      final labelPerMtr = repeatMm > 0 ? (1000.0 / repeatMm) : 3.53;
      _labelPerMtrController.text = labelPerMtr.toStringAsFixed(2);

      // 4. Paper Size (Web Width mm)
      final webWidth = product.machineSpec.webWidthMm > 0 ? product.machineSpec.webWidthMm.toInt() : 290;
      _paperSizeController.text = webWidth.toString();

      // 5. UPS (Web Up / Total Ups)
      final totalUps = product.machineSpec.totalUps > 0 ? product.machineSpec.totalUps : 1;
      _upsController.text = totalUps.toString();

      // 6. Substrate & Material
      _materialAndCodeController.text = product.labelSpec.faceMaterial.isNotEmpty ? product.labelSpec.faceMaterial : 'AVERY';
      _productMaterialTypeController.text = product.labelSpec.substrateMaterial.isNotEmpty ? product.labelSpec.substrateMaterial : 'C-MIRRORCOAT';

      // 7. Colors & Special Colors
      final colorCnt = product.printSpec.colorCount;
      _noOfColorsController.text = colorCnt > 0 ? (colorCnt == 4 ? 'CMYK' : '$colorCnt COLOR') : 'CMYK';
      _specialColorsController.text = product.printSpec.pantoneCodes.isNotEmpty ? product.printSpec.pantoneCodes : 'P 353 C / P 2727 C';
      _asPerShadeCard = 'Yes';

      // 8. UV Gloss / Lamination & Mat
      _uvGlossLaminationController.text = product.printSpec.varnishType.isNotEmpty && product.printSpec.varnishType != 'None'
          ? product.printSpec.varnishType
          : 'Gloss UV';
      _uvMat = product.printSpec.varnishType.toLowerCase().contains('mat') ? 'Yes' : 'No';

      // 9. Numbering & Winding Direction
      _numbering = product.printSpec.hasNumbering ? 'Yes' : 'No';
      _rollWindingDirection = product.machineSpec.windingDirection.isNotEmpty ? product.machineSpec.windingDirection : 'Head First';

      // 10. Check PO line item for order quantity
      if (_selectedPO != null && _selectedPO!.lineItems.isNotEmpty) {
        final poLine = _selectedPO!.lineItems.where((l) {
          return l.itemName.toLowerCase().trim() == product.productName.toLowerCase().trim() ||
              l.ourSkuCode == product.internalSkuCode ||
              l.customerSkuCode == product.internalSkuCode;
        }).firstOrNull ?? _selectedPO!.lineItems.first;

        if (poLine.quantityPcs > 0) {
          _targetQtyController.text = poLine.quantityPcs.toInt().toString();
          _plannedQtyController.text = (poLine.quantityPcs * 1.03).toInt().toString();
        }
      } else if (_targetQtyController.text.isEmpty || _targetQtyController.text == '0') {
        _targetQtyController.text = '75000';
        _plannedQtyController.text = '77250';
      }

      // 11. Recalculate RMT
      _recalculateRMT();
    });

    if (!isInitialPoSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auto-filled specs for SKU [${product.productName}] (Gear: ${_gearSizeController.text}, Paper Size: ${_paperSizeController.text}mm, RMT: ${_rmtController.text})'),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showManualPoDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: _poNumberController.text);
        return AlertDialog(
          title: const Text('Enter Custom PO Number'),
          content: TextFormField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'PO Number',
              hintText: 'e.g. PO:05051 or CUSTOM-PO-99',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _poNumberController.text = ctrl.text.trim();
                  _selectedPO = null;
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Set PO'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _jobCardNoController.dispose();
    _dateStrController.dispose();
    _machineNameController.dispose();
    _poNumberController.dispose();
    _poDateStrController.dispose();
    _jobCodeController.dispose();
    _cqalNoController.dispose();
    _customerNameController.dispose();
    _jobNameController.dispose();
    _labelSizeController.dispose();
    _labelPerMtrController.dispose();
    _stockLabelQtyController.dispose();
    _artWorkNoController.dispose();
    _gearSizeController.dispose();
    _noOfColorsController.dispose();
    _specialColorsController.dispose();
    _materialAndCodeController.dispose();
    _productMaterialTypeController.dispose();
    _uvGlossLaminationController.dispose();
    _targetQtyController.dispose();
    _plannedQtyController.dispose();
    _paperSizeController.dispose();
    _upsController.dispose();
    _rmtController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(jobCardRepositoryProvider);

      final customerName = _selectedCustomer?.companyName ?? _customerNameController.text.trim();
      final productName = _selectedProduct?.productName ?? _jobNameController.text.trim();

      final jobCardData = JobCardModel(
        id: widget.jobCard?.id ?? '',
        plantId: DefaultPlant.id,
        jobCardNo: _jobCardNoController.text.trim(),
        dateStr: _dateStrController.text.trim(),
        machineName: _machineNameController.text.trim(),
        orderId: widget.jobCard?.orderId ?? 'order-manual',
        poNumber: _poNumberController.text.trim(),
        poDateStr: _poDateStrController.text.trim(),
        customerId: _selectedCustomer?.id ?? widget.jobCard?.customerId ?? '',
        customerName: customerName,
        productId: _selectedProduct?.id ?? widget.jobCard?.productId ?? '',
        internalSkuCode: _selectedProduct?.internalSkuCode ?? widget.jobCard?.internalSkuCode ?? '',
        productName: productName,
        jobCode: _jobCodeController.text.trim(),
        cqalNo: _cqalNoController.text.trim(),
        labelSize: _labelSizeController.text.trim(),
        labelPerMtr: double.tryParse(_labelPerMtrController.text.trim()) ?? 1.0,
        stockLabelQty: double.tryParse(_stockLabelQtyController.text.trim()) ?? 0.0,
        artWorkNo: _artWorkNoController.text.trim(),
        rollWindingDirection: _rollWindingDirection,
        gearSize: _gearSizeController.text.trim(),
        numbering: _numbering,
        punchOnline: _punchOnline,
        punchType: _punchType,
        specialInfo: _specialInfo,
        plateOldNew: _plateOldNew,
        reslamDelam: _reslamDelam,
        noOfColors: _noOfColorsController.text.trim(),
        materialAndCode: _materialAndCodeController.text.trim(),
        asPerShadeCard: _asPerShadeCard,
        specialColors: _specialColorsController.text.trim(),
        productMaterialType: _productMaterialTypeController.text.trim(),
        uvGlossLamination: _uvGlossLaminationController.text.trim(),
        uvMat: _uvMat,
        textureVarnish: _textureVarnish,
        screenDetails: _screenDetails,
        stampingDetails: _stampingDetails,
        targetOrderQty: double.tryParse(_targetQtyController.text.trim()) ?? 0.0,
        plannedProductionQty: double.tryParse(_plannedQtyController.text.trim()) ?? 0.0,
        paperSize: double.tryParse(_paperSizeController.text.trim()) ?? 0.0,
        ups: int.tryParse(_upsController.text.trim()) ?? 1,
        rmt: double.tryParse(_rmtController.text.trim()) ?? 0.0,
        remarks: _remarksController.text.trim(),
        plateId: _selectedPlate?.id ?? widget.jobCard?.plateId ?? '',
        plateCode: _selectedPlate?.plateCode ?? widget.jobCard?.plateCode ?? '',
        dieId: _selectedDie?.id ?? widget.jobCard?.dieId ?? '',
        dieCode: _selectedDie?.dieCode ?? widget.jobCard?.dieCode ?? '',
        processRoute: _selectedProduct?.processRoute ?? widget.jobCard?.processRoute ?? StandardProcessSteps.defaultRoute,
        status: widget.jobCard?.status ?? JobCardStatus.draft,
        createdAt: widget.jobCard?.createdAt ?? DateTime.now(),
        createdBy: widget.jobCard?.createdBy ?? 'system',
        updatedAt: widget.jobCard != null ? DateTime.now() : null,
        updatedBy: widget.jobCard != null ? 'system' : null,
      );

      if (widget.jobCard == null) {
        await repo.createJobCard(jobCardData);
      } else {
        await repo.updateJobCard(jobCardData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.jobCard == null ? 'Job Sheet issued successfully' : 'Job Sheet updated successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving Job Card: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  JobCardModel _buildJobCardFromForm() {
    final customerName = _selectedCustomer?.companyName ?? _customerNameController.text.trim();
    final productName = _selectedProduct?.productName ?? _jobNameController.text.trim();

    return JobCardModel(
      id: widget.jobCard?.id ?? '',
      plantId: DefaultPlant.id,
      jobCardNo: _jobCardNoController.text.trim().isNotEmpty ? _jobCardNoController.text.trim() : '08/001',
      dateStr: _dateStrController.text.trim(),
      machineName: _machineNameController.text.trim(),
      orderId: widget.jobCard?.orderId ?? 'order-manual',
      poNumber: _poNumberController.text.trim(),
      poDateStr: _poDateStrController.text.trim(),
      customerId: _selectedCustomer?.id ?? widget.jobCard?.customerId ?? '',
      customerName: customerName,
      productId: _selectedProduct?.id ?? widget.jobCard?.productId ?? '',
      internalSkuCode: _selectedProduct?.internalSkuCode ?? widget.jobCard?.internalSkuCode ?? '',
      productName: productName,
      jobCode: _jobCodeController.text.trim(),
      cqalNo: _cqalNoController.text.trim(),
      labelSize: _labelSizeController.text.trim(),
      labelPerMtr: double.tryParse(_labelPerMtrController.text.trim()) ?? 1.0,
      stockLabelQty: double.tryParse(_stockLabelQtyController.text.trim()) ?? 0.0,
      artWorkNo: _artWorkNoController.text.trim(),
      rollWindingDirection: _rollWindingDirection,
      gearSize: _gearSizeController.text.trim(),
      numbering: _numbering,
      punchOnline: _punchOnline,
      punchType: _punchType,
      specialInfo: _specialInfo,
      plateOldNew: _plateOldNew,
      reslamDelam: _reslamDelam,
      noOfColors: _noOfColorsController.text.trim(),
      materialAndCode: _materialAndCodeController.text.trim(),
      asPerShadeCard: _asPerShadeCard,
      specialColors: _specialColorsController.text.trim(),
      productMaterialType: _productMaterialTypeController.text.trim(),
      uvGlossLamination: _uvGlossLaminationController.text.trim(),
      uvMat: _uvMat,
      textureVarnish: _textureVarnish,
      screenDetails: _screenDetails,
      stampingDetails: _stampingDetails,
      targetOrderQty: double.tryParse(_targetQtyController.text.trim()) ?? 0.0,
      plannedProductionQty: double.tryParse(_plannedQtyController.text.trim()) ?? 0.0,
      paperSize: double.tryParse(_paperSizeController.text.trim()) ?? 0.0,
      ups: int.tryParse(_upsController.text.trim()) ?? 1,
      rmt: double.tryParse(_rmtController.text.trim()) ?? 0.0,
      remarks: _remarksController.text.trim(),
      plateId: _selectedPlate?.id ?? widget.jobCard?.plateId ?? '',
      plateCode: _selectedPlate?.plateCode ?? widget.jobCard?.plateCode ?? '',
      dieId: _selectedDie?.id ?? widget.jobCard?.dieId ?? '',
      dieCode: _selectedDie?.dieCode ?? widget.jobCard?.dieCode ?? '',
      processRoute: _selectedProduct?.processRoute ?? widget.jobCard?.processRoute ?? StandardProcessSteps.defaultRoute,
      status: widget.jobCard?.status ?? JobCardStatus.draft,
      createdAt: widget.jobCard?.createdAt ?? DateTime.now(),
      createdBy: widget.jobCard?.createdBy ?? 'system',
      updatedAt: widget.jobCard != null ? DateTime.now() : null,
      updatedBy: widget.jobCard != null ? 'system' : null,
    );
  }

  void _handlePrint() {
    final currentCard = _buildJobCardFromForm();
    JobSheetPdfGenerator.printOrDownloadPdf(currentCard);
  }

  Widget _buildCellLabel(String text, {int flex = 1, Color? bg}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: bg ?? Colors.grey.shade200,
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildCellInput({
    required TextEditingController controller,
    int flex = 1,
    Color? bg,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        decoration: BoxDecoration(
          color: bg ?? Colors.white,
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }

  Widget _buildCellDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            isDense: true,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(activeCustomersFutureProvider);
    final productsAsync = ref.watch(productsStreamProvider(_selectedCustomer?.id));
    final platesAsync = ref.watch(platesStreamProvider(_selectedProduct?.id));
    final diesAsync = ref.watch(diesStreamProvider(_selectedProduct?.id));
    final ordersAsync = ref.watch(ordersStreamProvider);
    final openPOs = _getAvailableOpenOrders(ordersAsync.value ?? []);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.jobCard == null ? 'Issue New Job Sheet (PGPL)' : 'Edit Job Sheet (${widget.jobCard!.jobCardNo})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Auto Next Number',
            onPressed: _fetchNextJobCardNumber,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1050),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2)],
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Excel Title Header
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5), color: Colors.grey.shade100),
                    child: const Text('PRAKRUTI GRAPHICS PVT LTD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5), color: Colors.grey.shade200),
                    child: const Text('JOB SHEET', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  _buildRow([
                    _buildCellLabel('Machine Line:', flex: 2),
                    _buildCellInput(controller: _machineNameController, flex: 8, bg: Colors.amber.shade50),
                  ]),

                  // Grid Row 4: Job Sheet No, Date
                  _buildRow([
                    _buildCellLabel('Job Sheet No', flex: 2),
                    _buildCellInput(
                      controller: _jobCardNoController,
                      flex: 3,
                      bg: Colors.amber.shade100,
                      suffixIcon: _isLoadingAutoNum
                          ? const Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)))
                          : IconButton(
                              icon: const Icon(Icons.refresh, size: 16),
                              onPressed: _fetchNextJobCardNumber,
                            ),
                    ),
                    _buildCellLabel('Date:', flex: 2),
                    _buildCellInput(controller: _dateStrController, flex: 3),
                  ]),

                  // Grid Row 5: PO No (Smart Open PO Dropdown & Manual Input), PO Date
                  _buildRow([
                    _buildCellLabel('PO No:', flex: 2),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          border: Border.all(color: Colors.black, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<OrderModel>(
                                  value: openPOs.any((o) => o.id == _selectedPO?.id || o.poNumber == _poNumberController.text)
                                      ? openPOs.firstWhere((o) => o.id == _selectedPO?.id || o.poNumber == _poNumberController.text)
                                      : null,
                                  hint: Text(
                                    _poNumberController.text.isNotEmpty ? _poNumberController.text : 'Select Open PO...',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  isExpanded: true,
                                  isDense: true,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                                  items: openPOs.map((po) {
                                    return DropdownMenuItem<OrderModel>(
                                      value: po,
                                      child: Text(
                                        '${po.poNumber} (${po.customerName})',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      _onPOSelected(val, customersAsync.value ?? [], productsAsync.value ?? []);
                                    }
                                  },
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _showManualPoDialog,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: Icon(Icons.edit_note, size: 16, color: AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildCellLabel('PO Date:', flex: 2),
                    _buildCellInput(controller: _poDateStrController, flex: 3),
                  ]),

                  // Grid Row 6: JOB CODE, NO, u
                  _buildRow([
                    _buildCellLabel('JOB CODE', flex: 2),
                    _buildCellInput(controller: _jobCodeController, flex: 3, bg: Colors.amber.shade50),
                    _buildCellLabel('NO', flex: 1),
                    _buildCellInput(controller: TextEditingController(), flex: 2),
                    _buildCellLabel('u', flex: 1),
                    _buildCellInput(controller: TextEditingController(), flex: 1),
                  ]),

                  // Grid Row 7: Customer Name
                  _buildRow([
                    _buildCellLabel('Customer Name', flex: 2),
                    Expanded(
                      flex: 8,
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
                        child: customersAsync.when(
                          data: (customers) => DropdownButtonHideUnderline(
                            child: DropdownButton<CustomerModel>(
                              value: _selectedCustomer,
                              hint: Text(_customerNameController.text),
                              isExpanded: true,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                              items: customers
                                  .map((c) => DropdownMenuItem(value: c, child: Text('${c.companyName} (${c.customerCode})')))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedCustomer = val;
                                    _customerNameController.text = val.companyName;
                                    _selectedProduct = null;
                                  });
                                }
                              },
                            ),
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => TextFormField(
                            controller: _customerNameController,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8)),
                          ),
                        ),
                      ),
                    ),
                  ]),

                  // Grid Row 8: Job Name, CQAL No
                  _buildRow([
                    _buildCellLabel('Job Name', flex: 2),
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
                        child: productsAsync.when(
                          data: (products) {
                            final availableProducts = _getAvailableProductsForPO(products);
                            return DropdownButtonHideUnderline(
                              child: DropdownButton<ProductModel>(
                                value: availableProducts.any((p) => p.id == _selectedProduct?.id || p.productName == _jobNameController.text)
                                    ? availableProducts.firstWhere((p) => p.id == _selectedProduct?.id || p.productName == _jobNameController.text)
                                    : null,
                                hint: Text(_jobNameController.text.isNotEmpty ? _jobNameController.text : 'Select PO SKU / Job Name...'),
                                isExpanded: true,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                                items: availableProducts
                                    .map((p) => DropdownMenuItem<ProductModel>(
                                          value: p,
                                          child: Text('${p.productName} (${p.internalSkuCode.isNotEmpty ? p.internalSkuCode : 'SKU'})'),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    _onSKUSelected(val);
                                  }
                                },
                              ),
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => TextFormField(
                            controller: _jobNameController,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8)),
                          ),
                        ),
                      ),
                    ),
                    _buildCellLabel('CQAL No', flex: 1),
                    _buildCellInput(controller: _cqalNoController, flex: 2),
                  ]),

                  // Grid Row 9: Label Size, LABLE/MTR
                  _buildRow([
                    _buildCellLabel('Label Size', flex: 2),
                    _buildCellInput(controller: _labelSizeController, flex: 3),
                    _buildCellLabel('LABLE/MTR', flex: 2),
                    _buildCellInput(
                      controller: _labelPerMtrController,
                      flex: 3,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _recalculateRMT(),
                    ),
                  ]),

                  // Grid Row 10: Stock Label Qty
                  _buildRow([
                    _buildCellLabel('Stock Label Qty', flex: 2),
                    _buildCellInput(controller: _stockLabelQtyController, flex: 8, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  ]),

                  // Grid Row 11: Artwork No, Direction, Gear Size
                  _buildRow([
                    _buildCellLabel('Art Work No:', flex: 2),
                    _buildCellInput(controller: _artWorkNoController, flex: 2),
                    _buildCellLabel('Direction:', flex: 2),
                    _buildCellLabel(_rollWindingDirection, flex: 1, bg: Colors.amber.shade200),
                    _buildCellLabel('Gear Size:', flex: 1),
                    _buildCellInput(controller: _gearSizeController, flex: 2),
                  ]),

                  // Grid Row 12: Numbering, Punch Online, Punch
                  _buildRow([
                    _buildCellLabel('Numbering', flex: 2),
                    _buildCellDropdown<String>(
                      value: _numbering,
                      items: ['No', 'Yes'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _numbering = v ?? 'No'),
                      flex: 2,
                    ),
                    _buildCellLabel('Punch Online', flex: 2),
                    _buildCellDropdown<String>(
                      value: _punchOnline,
                      items: ['No', 'Yes'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _punchOnline = v ?? 'No'),
                      flex: 1,
                    ),
                    _buildCellLabel('Punch', flex: 1),
                    _buildCellDropdown<String>(
                      value: _punchType,
                      items: ['ONLINE', 'OFFLINE'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _punchType = v ?? 'ONLINE'),
                      flex: 2,
                    ),
                  ]),

                  // Grid Row 13: Special Info, Plate Old/New
                  _buildRow([
                    _buildCellLabel('Special Info', flex: 2),
                    _buildCellDropdown<String>(
                      value: _specialInfo,
                      items: ['No', 'Yes'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _specialInfo = v ?? 'No'),
                      flex: 3,
                    ),
                    _buildCellLabel('Plate Old/New', flex: 2),
                    _buildCellDropdown<String>(
                      value: _plateOldNew,
                      items: ['NEW', 'OLD', 'PARTIAL REMAKE (Colors Changed)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _plateOldNew = v ?? 'NEW'),
                      flex: 3,
                    ),
                  ]),

                  // Grid Row 14: Reslam/Delam, No of color, Material & Code
                  _buildRow([
                    _buildCellLabel('Reslam / Delam', flex: 2),
                    _buildCellDropdown<String>(
                      value: _reslamDelam,
                      items: ['No', 'Yes'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _reslamDelam = v ?? 'No'),
                      flex: 2,
                    ),
                    _buildCellLabel('No of color', flex: 2),
                    _buildCellInput(controller: _noOfColorsController, flex: 2),
                    _buildCellLabel('Material & Code', flex: 1),
                    _buildCellInput(controller: _materialAndCodeController, flex: 1),
                  ]),

                  // Grid Row 15: As per shade Card, Special Color, Product
                  _buildRow([
                    _buildCellLabel('As per shade Card', flex: 2),
                    _buildCellDropdown<String>(
                      value: _asPerShadeCard,
                      items: ['Yes', 'No'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _asPerShadeCard = v ?? 'Yes'),
                      flex: 1,
                    ),
                    _buildCellLabel('Special Color:', flex: 2),
                    _buildCellInput(controller: _specialColorsController, flex: 3),
                    _buildCellLabel('Product:', flex: 1),
                    _buildCellInput(controller: _productMaterialTypeController, flex: 1),
                  ]),

                  // Grid Row 16: UV Gloss/Lamination, Order Qty, Paper Size
                  _buildRow([
                    _buildCellLabel('UV Gloss/Lamination', flex: 2),
                    _buildCellInput(controller: _uvGlossLaminationController, flex: 2),
                    _buildCellLabel('Order Qty', flex: 2),
                    _buildCellInput(
                      controller: _targetQtyController,
                      flex: 2,
                      bg: Colors.amber.shade50,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _recalculateRMT(),
                    ),
                    _buildCellLabel('Paper Size', flex: 1),
                    _buildCellInput(controller: _paperSizeController, flex: 1, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  ]),

                  // Grid Row 17: UV Mat, Screen Details, UPS
                  _buildRow([
                    _buildCellLabel('UV Mat', flex: 2),
                    _buildCellDropdown<String>(
                      value: _uvMat,
                      items: ['No', 'Yes'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _uvMat = v ?? 'No'),
                      flex: 2,
                    ),
                    _buildCellLabel('Screen Details :', flex: 2),
                    _buildCellDropdown<String>(
                      value: _screenDetails,
                      items: ['No', 'Yes'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _screenDetails = v ?? 'No'),
                      flex: 2,
                    ),
                    _buildCellLabel('UPS', flex: 1),
                    _buildCellInput(
                      controller: _upsController,
                      flex: 1,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculateRMT(),
                    ),
                  ]),

                  // Grid Row 18: Texture Varnish, Stamping Details, RMT
                  _buildRow([
                    _buildCellLabel('Texture Varnish', flex: 2),
                    _buildCellDropdown<String>(
                      value: _textureVarnish,
                      items: ['No', 'Yes'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _textureVarnish = v ?? 'No'),
                      flex: 2,
                    ),
                    _buildCellLabel('Stamping Details:', flex: 2),
                    _buildCellDropdown<String>(
                      value: _stampingDetails,
                      items: ['No', 'Yes'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _stampingDetails = v ?? 'No'),
                      flex: 2,
                    ),
                    _buildCellLabel('RMT', flex: 1),
                    _buildCellInput(controller: _rmtController, flex: 1, bg: Colors.amber.shade100, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  ]),

                  // Grid Row 19: Remarks
                  _buildRow([
                    _buildCellLabel('Remarks', flex: 2),
                    _buildCellInput(controller: _remarksController, flex: 8),
                  ]),

                  const SizedBox(height: 14),

                  // Roll Winding Direction Picker with Visual Diagrams (F1-F4, R1-R4)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.black, width: 0.5)),
                    alignment: Alignment.center,
                    child: const Text('Roll Winding Direction (Click to select F1 - R4)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  RollWindingDiagramWidget(
                    selectedDirection: _rollWindingDirection,
                    onDirectionSelected: (dir) => setState(() => _rollWindingDirection = dir),
                  ),

                  const SizedBox(height: 14),

                  // Production Details Table
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.black, width: 0.5)),
                    alignment: Alignment.center,
                    child: const Text('Production Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  _buildRow([
                    _buildCellLabel('Date', flex: 2),
                    _buildCellLabel('Operator', flex: 2),
                    _buildCellLabel('Print RMT', flex: 2),
                    _buildCellLabel('Print Qty', flex: 2),
                    _buildCellLabel('Wastage', flex: 2),
                    _buildCellLabel('Total Prod.Time Used', flex: 3),
                  ]),
                  for (int i = 0; i < 3; i++)
                    _buildRow([
                      _buildCellInput(controller: TextEditingController(), flex: 2),
                      _buildCellInput(controller: TextEditingController(), flex: 2),
                      _buildCellInput(controller: TextEditingController(), flex: 2, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      _buildCellInput(controller: TextEditingController(), flex: 2, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      _buildCellInput(controller: TextEditingController(), flex: 2, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      _buildCellInput(controller: TextEditingController(), flex: 3),
                    ]),
                  _buildRow([
                    _buildCellLabel('Total RMT=', flex: 4),
                    _buildCellInput(controller: TextEditingController(), flex: 9, bg: Colors.amber.shade50),
                  ]),

                  const SizedBox(height: 14),

                  // Actual Production Details Table
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.black, width: 0.5)),
                    alignment: Alignment.center,
                    child: const Text('Actual Production Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  _buildRow([
                    _buildCellLabel('Roll Id', flex: 2),
                    _buildCellLabel('From Store', flex: 2),
                    _buildCellLabel('Printing Rmt', flex: 2),
                    _buildCellLabel('Setting Rmt', flex: 2),
                    _buildCellLabel('Wastage Rmt', flex: 2),
                    _buildCellLabel('Leftover', flex: 2),
                  ]),
                  for (int i = 0; i < 3; i++)
                    _buildRow([
                      _buildCellInput(controller: TextEditingController(), flex: 2),
                      _buildCellInput(controller: TextEditingController(), flex: 2),
                      _buildCellInput(controller: TextEditingController(), flex: 2, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      _buildCellInput(controller: TextEditingController(), flex: 2, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      _buildCellInput(controller: TextEditingController(), flex: 2, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      _buildCellInput(controller: TextEditingController(), flex: 2, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                    ]),
                  _buildRow([
                    _buildCellLabel('Total RMT=', flex: 4),
                    _buildCellInput(controller: TextEditingController(), flex: 8, bg: Colors.amber.shade50),
                  ]),

                  const SizedBox(height: 14),

                  // Post Production Details Table
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.black, width: 0.5)),
                    alignment: Alignment.center,
                    child: const Text('Post Production Details At Final Inspection & Dispatch Stage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  _buildRow([
                    _buildCellLabel('Date', flex: 2),
                    _buildCellLabel('Inspected', flex: 2),
                    _buildCellLabel('Ok Quantity', flex: 2),
                    _buildCellLabel('Rejected Quantity', flex: 2),
                    _buildCellLabel('% Rejection', flex: 2),
                    _buildCellLabel('Sign Dh (PTG)', flex: 2),
                  ]),
                  for (int i = 0; i < 2; i++)
                    _buildRow([
                      _buildCellInput(controller: TextEditingController(), flex: 2),
                      _buildCellInput(controller: TextEditingController(), flex: 2),
                      _buildCellInput(controller: TextEditingController(), flex: 2, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      _buildCellInput(controller: TextEditingController(), flex: 2, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      _buildCellInput(controller: TextEditingController(), flex: 2),
                      _buildCellInput(controller: TextEditingController(), flex: 2),
                    ]),

                  const SizedBox(height: 14),

                  // Raw Material Issue & Tooling Allocation
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.black, width: 0.5)),
                    alignment: Alignment.center,
                    child: const Text('Raw Material Issue Sheet & Tooling Allocation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  _buildRow([
                    _buildCellLabel('Paper : Chroma/ MirrorCoat', flex: 4),
                    _buildCellInput(controller: _productMaterialTypeController, flex: 3),
                    _buildCellLabel('Paper Size:', flex: 2),
                    _buildCellInput(controller: _paperSizeController, flex: 2),
                    _buildCellLabel('R/M:', flex: 2),
                    _buildCellInput(controller: TextEditingController(), flex: 3),
                  ]),
                  _buildRow([
                    _buildCellLabel('Plate :', flex: 3),
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
                        child: platesAsync.when(
                          data: (plates) => DropdownButtonHideUnderline(
                            child: DropdownButton<PlateModel>(
                              value: _selectedPlate,
                              hint: Text(_selectedPlate?.plateCode ?? 'Select Plate Code'),
                              isExpanded: true,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                              items: plates
                                  .map((p) => DropdownMenuItem(value: p, child: Text('${p.plateCode} (${p.colorCount} Colors)')))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedPlate = val),
                            ),
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const Padding(padding: EdgeInsets.all(8), child: Text('No Plate Assigned', style: TextStyle(fontSize: 12))),
                        ),
                      ),
                    ),
                    _buildCellLabel('No. Of Plate :', flex: 3),
                    _buildCellInput(controller: TextEditingController(), flex: 5),
                  ]),
                  _buildRow([
                    _buildCellLabel('Die :', flex: 3),
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
                        child: diesAsync.when(
                          data: (dies) => DropdownButtonHideUnderline(
                            child: DropdownButton<DieModel>(
                              value: _selectedDie,
                              hint: Text(_selectedDie?.dieCode ?? 'Select Die Code'),
                              isExpanded: true,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                              items: dies
                                  .map((d) => DropdownMenuItem(value: d, child: Text('${d.dieCode} (${d.specLabel})')))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedDie = val),
                            ),
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const Padding(padding: EdgeInsets.all(8), child: Text('No Die Assigned', style: TextStyle(fontSize: 12))),
                        ),
                      ),
                    ),
                    _buildCellLabel('Online', flex: 2),
                    _buildCellInput(controller: TextEditingController(), flex: 2),
                    _buildCellLabel('u', flex: 1),
                    _buildCellInput(controller: TextEditingController(), flex: 1),
                    _buildCellLabel('Offline', flex: 2),
                    _buildCellInput(controller: TextEditingController(), flex: 2),
                  ]),

                  const SizedBox(height: 14),

                  // Despatch Details Table
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.black, width: 0.5)),
                    alignment: Alignment.center,
                    child: const Text('Despatch Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  _buildRow([
                    _buildCellLabel('DC/Invoice NO. PGPL/22-23/', flex: 4),
                    _buildCellInput(controller: TextEditingController(), flex: 2),
                    _buildCellLabel('Date:', flex: 2),
                    _buildCellInput(controller: TextEditingController(), flex: 2),
                    _buildCellLabel('Despatched Qty', flex: 3),
                    _buildCellInput(controller: TextEditingController(), flex: 3),
                  ]),
                  _buildRow([
                    _buildCellLabel('DC/Invoice NO. PGPL/22-23/', flex: 4),
                    _buildCellInput(controller: TextEditingController(), flex: 2),
                    _buildCellLabel('Date:', flex: 2),
                    _buildCellInput(controller: TextEditingController(), flex: 2),
                    _buildCellLabel('', flex: 3),
                    _buildCellInput(controller: TextEditingController(), flex: 3),
                  ]),
                  _buildRow([
                    _buildCellLabel('DC/Invoice NO. PGPL/22-23/', flex: 4),
                    _buildCellInput(controller: TextEditingController(), flex: 2),
                    _buildCellLabel('Date:', flex: 2),
                    _buildCellInput(controller: TextEditingController(), flex: 2),
                    _buildCellLabel('Bal Qty .', flex: 3),
                    _buildCellInput(controller: TextEditingController(), flex: 3),
                  ]),

                  const SizedBox(height: 24),

                  // Bottom Buttons Row: Print/Download PDF & Save Job Sheet
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _handlePrint,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.primary, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            icon: const Icon(Icons.print_outlined, size: 22, color: AppTheme.primary),
                            label: const Text(
                              'Print / Download PDF',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            icon: _isSaving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.check_circle_outline, size: 22),
                            label: Text(
                              _isSaving ? 'Saving Job Sheet...' : 'Issue / Save PGPL Job Sheet',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Master Job Card PDF Attachments (4 Pages)
                  const JobCardAttachmentsWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




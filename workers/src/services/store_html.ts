import type { StorePageData, StoreProduct } from '../types/store_page';

function escapeHtml(raw: string): string {
	return raw
		.replaceAll('&', '&amp;')
		.replaceAll('<', '&lt;')
		.replaceAll('>', '&gt;')
		.replaceAll('"', '&quot;')
		.replaceAll("'", '&#39;');
}

function escapeJson(data: unknown): string {
	return JSON.stringify(data)
		.replace(/</g, '\\u003c')
		.replace(/>/g, '\\u003e')
		.replace(/&/g, '\\u0026');
}

function waPhone(raw: string | undefined): string {
	const digits = (raw ?? '').replace(/[^0-9]/g, '');
	if (!digits) {
		return '';
	}

	if (digits.length === 12 && digits.startsWith('91')) {
		return digits;
	}

	if (digits.length >= 10) {
		return `91${digits.slice(digits.length - 10)}`;
	}

	return digits;
}

function currency(amount: number): string {
	return `Rs ${Math.round(amount)}`;
}

function renderProductCard(product: StoreProduct): string {
	const media = product.imageUrl
		? `<img class="product-image" src="${escapeHtml(product.imageUrl)}" alt="${escapeHtml(product.name)}" loading="lazy" />`
		: `<div class="product-placeholder">${escapeHtml(product.name.slice(0, 1).toUpperCase())}</div>`;

	return `<article class="product-card" data-product-id="${escapeHtml(product.id)}">
		${media}
		<div class="product-copy">
			<div class="product-topline">
				<span class="stock-pill">${product.stockStatus === 'lowStock' ? 'Low stock' : 'In stock'}</span>
			</div>
			<h3 class="product-name">${escapeHtml(product.name)}</h3>
			<p class="product-price">${currency(product.price)}</p>
			<button class="add-btn" type="button" data-add-product="${escapeHtml(product.id)}">Add to Cart</button>
		</div>
	</article>`;
}

export function renderStoreHtml(data: StorePageData, slug: string): string {
	const shopName = escapeHtml(data.shop.shopName || 'Dukaan Store');
	const description = escapeHtml(
		data.shop.storeDescription || 'Products dekhiye, cart banaiye, aur online payment kijiye.',
	);
	const phone = waPhone(data.shop.phone);
	const bootstrap = escapeJson({
		store: {
			shopName: data.shop.shopName,
			slug: data.shop.slug,
			city: data.shop.city ?? '',
			bannerUrl: data.shop.storeBannerUrl ?? '',
			description: data.shop.storeDescription ?? '',
		},
		products: data.products,
	});
	const productCards = data.products.map((product) => renderProductCard(product)).join('');
	const contactHref = phone
		? `https://wa.me/${phone}?text=${encodeURIComponent(`Namaste ${data.shop.shopName} ji! Aapke store se order karna hai.`)}`
		: '';

	return `<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width,initial-scale=1" />
		<title>${shopName}</title>
		<meta name="description" content="${description}" />
		<meta property="og:title" content="${shopName}" />
		<meta property="og:description" content="${description}" />
		<meta property="og:type" content="website" />
		<meta property="og:url" content="https://dukaan.ai/s/${escapeHtml(slug)}" />
		<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
		<style>
			:root {
				--bg: #f7f1e8;
				--paper: #fffdf9;
				--ink: #1f1d1a;
				--muted: #6f675d;
				--line: rgba(31, 29, 26, 0.1);
				--brand: #d95f1a;
				--brand-dark: #a84411;
				--accent: #1f7a4f;
				--card: #ffffff;
				--shadow: 0 20px 40px rgba(88, 56, 24, 0.12);
				--radius: 18px;
			}
			* { box-sizing: border-box; }
			body {
				margin: 0;
				font-family: "Segoe UI", Arial, sans-serif;
				background:
					radial-gradient(circle at top left, rgba(217, 95, 26, 0.12), transparent 30%),
					radial-gradient(circle at top right, rgba(31, 122, 79, 0.08), transparent 28%),
					var(--bg);
				color: var(--ink);
			}
			button, input, textarea {
				font: inherit;
			}
			.page {
				max-width: 1240px;
				margin: 0 auto;
				padding: 24px 16px 40px;
			}
			.hero {
				background: var(--paper);
				border: 1px solid var(--line);
				border-radius: 24px;
				overflow: hidden;
				box-shadow: var(--shadow);
				margin-bottom: 24px;
			}
			.hero-banner {
				width: 100%;
				height: 220px;
				object-fit: cover;
				display: block;
				background: linear-gradient(135deg, #f0d7be, #f9efe5);
			}
			.hero-copy {
				padding: 24px;
			}
			.hero-kicker {
				color: var(--brand);
				font-size: 13px;
				font-weight: 700;
				text-transform: uppercase;
				letter-spacing: 0.08em;
			}
			.hero h1 {
				margin: 8px 0 6px;
				font-size: clamp(30px, 4vw, 42px);
				line-height: 1.05;
			}
			.hero p {
				margin: 0;
				max-width: 760px;
				color: var(--muted);
				font-size: 16px;
				line-height: 1.55;
			}
			.hero-actions {
				display: flex;
				flex-wrap: wrap;
				gap: 12px;
				margin-top: 18px;
			}
			.hero-chip {
				display: inline-flex;
				align-items: center;
				gap: 8px;
				padding: 10px 14px;
				border-radius: 999px;
				background: #fff4ec;
				color: var(--brand-dark);
				font-size: 14px;
				font-weight: 600;
				text-decoration: none;
			}
			.layout {
				display: grid;
				grid-template-columns: minmax(0, 1fr);
				gap: 24px;
			}
			.catalog-shell {
				background: rgba(255,255,255,0.55);
				border: 1px solid rgba(255,255,255,0.65);
				backdrop-filter: blur(8px);
				border-radius: 24px;
				padding: 18px;
			}
			.catalog-header {
				display: flex;
				justify-content: space-between;
				align-items: end;
				gap: 16px;
				margin-bottom: 16px;
			}
			.catalog-header h2 {
				margin: 0;
				font-size: 24px;
			}
			.catalog-header p {
				margin: 6px 0 0;
				color: var(--muted);
			}
			.product-grid {
				display: grid;
				grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
				gap: 16px;
			}
			.product-card {
				display: flex;
				flex-direction: column;
				background: var(--card);
				border-radius: var(--radius);
				border: 1px solid var(--line);
				overflow: hidden;
				min-height: 100%;
			}
			.product-image,
			.product-placeholder {
				width: 100%;
				aspect-ratio: 1 / 1;
				object-fit: cover;
				background: #efe4d4;
			}
			.product-placeholder {
				display: grid;
				place-items: center;
				font-size: 28px;
				font-weight: 700;
				color: var(--brand-dark);
			}
			.product-copy {
				padding: 14px;
				display: flex;
				flex: 1;
				flex-direction: column;
				gap: 10px;
			}
			.product-topline {
				display: flex;
				justify-content: space-between;
				align-items: center;
			}
			.stock-pill {
				display: inline-flex;
				padding: 6px 10px;
				border-radius: 999px;
				background: #edf7f1;
				color: var(--accent);
				font-size: 12px;
				font-weight: 700;
			}
			.product-name {
				margin: 0;
				font-size: 17px;
				line-height: 1.3;
			}
			.product-price {
				margin: 0;
				font-size: 20px;
				font-weight: 800;
				color: var(--brand-dark);
			}
			.add-btn,
			.pay-btn,
			.secondary-btn {
				border: 0;
				border-radius: 12px;
				padding: 12px 14px;
				font-weight: 700;
				cursor: pointer;
			}
			.add-btn,
			.pay-btn {
				background: var(--brand);
				color: #fff;
			}
			.add-btn:hover,
			.pay-btn:hover {
				background: var(--brand-dark);
			}
			.cart-panel {
				background: var(--paper);
				border: 1px solid var(--line);
				border-radius: 24px;
				padding: 18px;
				box-shadow: var(--shadow);
				position: sticky;
				top: 16px;
			}
			.cart-header {
				display: flex;
				align-items: center;
				justify-content: space-between;
				gap: 16px;
			}
			.cart-header h2,
			.success-card h2 {
				margin: 0;
				font-size: 24px;
			}
			.cart-subtitle {
				margin: 6px 0 0;
				color: var(--muted);
				font-size: 14px;
			}
			.cart-list {
				display: flex;
				flex-direction: column;
				gap: 10px;
				margin: 18px 0;
			}
			.cart-item {
				display: grid;
				grid-template-columns: 1fr auto;
				gap: 10px;
				padding: 12px;
				background: #fff;
				border: 1px solid var(--line);
				border-radius: 14px;
			}
			.cart-item-name {
				margin: 0 0 4px;
				font-weight: 700;
			}
			.cart-item-meta {
				margin: 0;
				font-size: 13px;
				color: var(--muted);
			}
			.qty-controls {
				display: inline-flex;
				align-items: center;
				gap: 8px;
				border-radius: 999px;
				border: 1px solid var(--line);
				padding: 4px;
			}
			.qty-controls button {
				width: 30px;
				height: 30px;
				border: 0;
				border-radius: 999px;
				background: #f4eee5;
				font-weight: 700;
				cursor: pointer;
			}
			.empty-cart {
				padding: 20px 12px;
				text-align: center;
				color: var(--muted);
				border: 1px dashed var(--line);
				border-radius: 14px;
				background: rgba(255,255,255,0.55);
			}
			.summary {
				display: grid;
				gap: 8px;
				padding: 14px 0;
				border-top: 1px solid var(--line);
				border-bottom: 1px solid var(--line);
			}
			.summary-row {
				display: flex;
				justify-content: space-between;
				gap: 10px;
			}
			.summary-row.total {
				font-size: 18px;
				font-weight: 800;
			}
			.form-grid {
				display: grid;
				gap: 12px;
				margin-top: 18px;
			}
			.field {
				display: grid;
				gap: 6px;
			}
			.field label {
				font-size: 13px;
				font-weight: 700;
			}
			.field input,
			.field textarea {
				width: 100%;
				border: 1px solid var(--line);
				border-radius: 12px;
				padding: 12px;
				background: #fff;
			}
			.field textarea {
				min-height: 88px;
				resize: vertical;
			}
			.helper {
				margin-top: 10px;
				font-size: 12px;
				color: var(--muted);
			}
			.status-message {
				min-height: 20px;
				margin-top: 12px;
				font-size: 13px;
				font-weight: 600;
			}
			.status-error { color: #b42318; }
			.status-success { color: var(--accent); }
			.pay-btn[disabled] {
				opacity: 0.65;
				cursor: not-allowed;
			}
			.success-card {
				display: none;
				background: var(--paper);
				border: 1px solid var(--line);
				border-radius: 24px;
				padding: 24px;
				box-shadow: var(--shadow);
			}
			.success-copy {
				margin: 10px 0 16px;
				font-size: 16px;
				line-height: 1.55;
				color: var(--muted);
			}
			.success-summary {
				display: grid;
				gap: 10px;
				padding: 16px;
				border-radius: 18px;
				border: 1px solid var(--line);
				background: #fff;
			}
			.success-list {
				margin: 0;
				padding-left: 18px;
			}
			@media (min-width: 980px) {
				.layout {
					grid-template-columns: minmax(0, 1.3fr) 380px;
					align-items: start;
				}
			}
			@media (max-width: 979px) {
				.page {
					padding-bottom: 120px;
				}
				.cart-panel {
					position: static;
				}
			}
		</style>
	</head>
	<body>
		<div class="page">
			<header class="hero">
				${data.shop.storeBannerUrl ? `<img class="hero-banner" src="${escapeHtml(data.shop.storeBannerUrl)}" alt="${shopName} banner" />` : ''}
				<div class="hero-copy">
					<div class="hero-kicker">Seller Store</div>
					<h1>${shopName}</h1>
					<p>${description}</p>
					<div class="hero-actions">
						<span class="hero-chip">${escapeHtml(String(data.products.length))} products live</span>
						${data.shop.city ? `<span class="hero-chip">${escapeHtml(data.shop.city)}</span>` : ''}
						${contactHref ? `<a class="hero-chip" href="${contactHref}" target="_blank" rel="noopener">WhatsApp se puchhiye</a>` : ''}
					</div>
				</div>
			</header>

			<section class="layout" id="checkout-shell">
				<div class="catalog-shell">
					<div class="catalog-header">
						<div>
							<h2>Products</h2>
							<p>Cart banaiye aur seedha online payment kijiye.</p>
						</div>
					</div>
					<div class="product-grid" id="product-grid">
						${productCards || '<div class="empty-cart">Abhi koi product available nahi hai.</div>'}
					</div>
				</div>

				<aside class="cart-panel">
					<div class="cart-header">
						<div>
							<h2>Your Cart</h2>
							<p class="cart-subtitle">Order place karne ke liye details bhariye.</p>
						</div>
						<span id="cart-count" class="hero-chip">0 items</span>
					</div>

					<div class="cart-list" id="cart-list">
						<div class="empty-cart">Cart abhi khaali hai.</div>
					</div>

					<div class="summary">
						<div class="summary-row"><span>Subtotal</span><strong id="subtotal">Rs 0</strong></div>
						<div class="summary-row"><span>Delivery</span><strong>Rs 0</strong></div>
						<div class="summary-row total"><span>Total</span><strong id="total">Rs 0</strong></div>
					</div>

					<div class="form-grid">
						<div class="field">
							<label for="customer-name">Customer name</label>
							<input id="customer-name" name="customer-name" type="text" placeholder="Aapka naam" maxlength="80" />
						</div>
						<div class="field">
							<label for="customer-phone">Phone number</label>
							<input id="customer-phone" name="customer-phone" type="tel" placeholder="98765XXXXX" maxlength="15" />
						</div>
						<div class="field">
							<label for="customer-address">Address</label>
							<textarea id="customer-address" name="customer-address" placeholder="Delivery address optional"></textarea>
						</div>
					</div>

					<button class="pay-btn" id="pay-now-btn" type="button">Pay Now</button>
					<div class="status-message" id="status-message"></div>
					<p class="helper">Payment ke baad WhatsApp pe confirmation aayega.</p>
				</aside>
			</section>

			<section class="success-card" id="success-card">
				<h2>Order confirmed</h2>
				<p class="success-copy" id="success-copy">Shukriya! Aapka order place ho gaya.</p>
				<div class="success-summary">
					<div class="summary-row total"><span>Total paid</span><strong id="success-total">Rs 0</strong></div>
					<div class="summary-row"><span>Order slip</span><strong id="success-slip-id">-</strong></div>
					<div class="summary-row"><span>Customer</span><strong id="success-customer">-</strong></div>
					<div>
						<strong>Items</strong>
						<ul class="success-list" id="success-items"></ul>
					</div>
				</div>
			</section>
		</div>

		<script>
			window.__STORE_DATA__ = ${bootstrap};
		</script>
		<script>
			(function () {
				const bootstrap = window.__STORE_DATA__ || { store: {}, products: [] };
				const products = Array.isArray(bootstrap.products) ? bootstrap.products : [];
				const productMap = new Map(products.map((product) => [product.id, product]));
				const cart = new Map();

				const productGrid = document.getElementById('product-grid');
				const cartList = document.getElementById('cart-list');
				const cartCount = document.getElementById('cart-count');
				const subtotalEl = document.getElementById('subtotal');
				const totalEl = document.getElementById('total');
				const payNowBtn = document.getElementById('pay-now-btn');
				const statusMessage = document.getElementById('status-message');
				const successCard = document.getElementById('success-card');
				const checkoutShell = document.getElementById('checkout-shell');

				function formatCurrency(amount) {
					return 'Rs ' + Math.round(amount || 0);
				}

				function getSummary() {
					let totalItems = 0;
					let subtotal = 0;
					const items = [];
					cart.forEach((quantity, productId) => {
						const product = productMap.get(productId);
						if (!product || quantity < 1) {
							return;
						}
						totalItems += quantity;
						subtotal += (Number(product.price) || 0) * quantity;
						items.push({
							productId: product.id,
							name: product.name,
							price: Number(product.price) || 0,
							quantity: quantity,
							subtotal: (Number(product.price) || 0) * quantity,
						});
					});
					return { totalItems, subtotal, total: subtotal, items };
				}

				function setStatus(message, kind) {
					statusMessage.textContent = message || '';
					statusMessage.className = 'status-message' + (kind ? ' status-' + kind : '');
				}

				function renderCart() {
					const summary = getSummary();
					cartCount.textContent = summary.totalItems + ' items';
					subtotalEl.textContent = formatCurrency(summary.subtotal);
					totalEl.textContent = formatCurrency(summary.total);
					payNowBtn.disabled = summary.totalItems === 0;

					if (!summary.items.length) {
						cartList.innerHTML = '<div class="empty-cart">Cart abhi khaali hai.</div>';
						return;
					}

					cartList.innerHTML = summary.items.map((item) => {
						return '<div class="cart-item">' +
							'<div>' +
								'<p class="cart-item-name">' + escapeHtml(item.name) + '</p>' +
								'<p class="cart-item-meta">' + formatCurrency(item.price) + ' each</p>' +
							'</div>' +
							'<div>' +
								'<div class="qty-controls">' +
									'<button type="button" data-qty-action="decrease" data-product-id="' + escapeHtml(item.productId) + '">-</button>' +
									'<strong>' + item.quantity + '</strong>' +
									'<button type="button" data-qty-action="increase" data-product-id="' + escapeHtml(item.productId) + '">+</button>' +
								'</div>' +
								'<p class="cart-item-meta">' + formatCurrency(item.subtotal) + '</p>' +
							'</div>' +
						'</div>';
					}).join('');
				}

				function escapeHtml(raw) {
					return String(raw)
						.replaceAll('&', '&amp;')
						.replaceAll('<', '&lt;')
						.replaceAll('>', '&gt;')
						.replaceAll('"', '&quot;')
						.replaceAll("'", '&#39;');
				}

				function updateQuantity(productId, delta) {
					const current = cart.get(productId) || 0;
					const next = current + delta;
					if (next <= 0) {
						cart.delete(productId);
					} else {
						cart.set(productId, next);
					}
					renderCart();
				}

				async function postJson(url, payload) {
					const response = await fetch(url, {
						method: 'POST',
						headers: { 'Content-Type': 'application/json' },
						body: JSON.stringify(payload),
					});
					let json = {};
					try {
						json = await response.json();
					} catch (error) {
						json = {};
					}
					return { response, json };
				}

				function readCustomer() {
					return {
						name: (document.getElementById('customer-name').value || '').trim(),
						phone: (document.getElementById('customer-phone').value || '').trim(),
						address: (document.getElementById('customer-address').value || '').trim(),
					};
				}

				function isValidPhone(rawPhone) {
					const digits = String(rawPhone || '').replace(/[^0-9]/g, '');
					return /^[6-9][0-9]{9}$/.test(digits.length === 12 && digits.startsWith('91') ? digits.slice(2) : digits.slice(-10));
				}

				async function fetchConfirmationCopy(shopName, summary) {
					try {
						const result = await postJson('/api/generate-order-confirmation', {
							language: 'hinglish',
							shopName: shopName,
							productSummary: summary.items.map((item) => item.name + ' x ' + item.quantity).join(', '),
						});
						return result.json && result.json.success && result.json.data
							? result.json.data.copy || ''
							: '';
					} catch (error) {
						return '';
					}
				}

				function renderSuccess(data, summary, copy) {
					checkoutShell.style.display = 'none';
					successCard.style.display = 'block';
					document.getElementById('success-copy').textContent = copy || 'Shukriya! Aapka order place ho gaya. Hum WhatsApp pe confirm karenge.';
					document.getElementById('success-total').textContent = formatCurrency(summary.total);
					document.getElementById('success-slip-id').textContent = data.orderSlipId || '-';
					document.getElementById('success-customer').textContent = data.customerName || '-';
					document.getElementById('success-items').innerHTML = summary.items
						.map((item) => '<li>' + escapeHtml(item.name) + ' x ' + item.quantity + '</li>')
						.join('');
				}

				async function startCheckout() {
					const summary = getSummary();
					if (!summary.items.length) {
						setStatus('Cart mein products add kijiye.', 'error');
						return;
					}

					const customer = readCustomer();
					if (!customer.name || !isValidPhone(customer.phone)) {
						setStatus('Sahi naam aur 10 digit phone number dijiye.', 'error');
						return;
					}

					setStatus('Order bana rahe hain...', 'success');
					payNowBtn.disabled = true;

					try {
						const createResult = await postJson('/api/store/create-order', {
							storeSlug: bootstrap.store.slug,
							items: summary.items.map((item) => ({
								productId: item.productId,
								quantity: item.quantity,
							})),
							customer: customer,
						});

						const createData = createResult.json && createResult.json.data ? createResult.json.data : null;
						if (!createResult.response.ok || !createData || !window.Razorpay) {
							throw new Error((createResult.json && createResult.json.error) || 'Order create nahi hua.');
						}

						const razorpay = new window.Razorpay({
							key: createData.razorpayKeyId,
							amount: createData.amountPaise,
							currency: createData.currency,
							order_id: createData.razorpayOrderId,
							name: createData.sellerName || bootstrap.store.shopName,
							description: 'Store order',
							prefill: {
								name: createData.customerName,
								contact: createData.customerPhone,
							},
							handler: async function (response) {
								setStatus('Payment verify kar rahe hain...', 'success');
								const verifyResult = await postJson('/api/store/verify-payment', {
									razorpayOrderId: response.razorpay_order_id,
									razorpayPaymentId: response.razorpay_payment_id,
									razorpaySignature: response.razorpay_signature,
								});

								if (!verifyResult.response.ok || !verifyResult.json.success) {
									setStatus('Payment verify nahi hua. Support se baat kijiye.', 'error');
									payNowBtn.disabled = false;
									return;
								}

								const copy = await fetchConfirmationCopy(
									createData.sellerName || bootstrap.store.shopName,
									summary,
								);

								renderSuccess(createData, summary, copy);
							},
							theme: { color: '#d95f1a' },
						});

						razorpay.on('payment.failed', function () {
							setStatus('Payment complete nahi hua. Dobara try kijiye.', 'error');
							payNowBtn.disabled = false;
						});

						razorpay.open();
					} catch (error) {
						setStatus(error && error.message ? error.message : 'Checkout start nahi hua.', 'error');
						payNowBtn.disabled = false;
					}
				}

				productGrid.addEventListener('click', function (event) {
					const target = event.target;
					if (!(target instanceof HTMLElement)) {
						return;
					}
					const productId = target.getAttribute('data-add-product');
					if (!productId) {
						return;
					}
					updateQuantity(productId, 1);
					setStatus('Product cart mein add ho gaya.', 'success');
				});

				cartList.addEventListener('click', function (event) {
					const target = event.target;
					if (!(target instanceof HTMLElement)) {
						return;
					}
					const action = target.getAttribute('data-qty-action');
					const productId = target.getAttribute('data-product-id');
					if (!action || !productId) {
						return;
					}
					updateQuantity(productId, action === 'increase' ? 1 : -1);
				});

				payNowBtn.addEventListener('click', startCheckout);
				renderCart();
			})();
		</script>
	</body>
</html>`;
}

export function renderStoreErrorHtml(
	title: string,
	message: string,
	ctaLabel = 'Dukaan AI kholo',
	ctaHref = 'https://dukaan.ai',
): string {
	const safeTitle = escapeHtml(title);
	const safeMessage = escapeHtml(message);
	const safeCtaLabel = escapeHtml(ctaLabel);
	const safeCtaHref = escapeHtml(ctaHref);

	return `<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width,initial-scale=1" />
		<title>${safeTitle}</title>
		<style>
			body {
				margin: 0;
				min-height: 100vh;
				display: grid;
				place-items: center;
				background: #f7f1e8;
				font-family: "Segoe UI", Arial, sans-serif;
				color: #1f1d1a;
			}
			.box {
				width: min(92vw, 420px);
				background: #fffdf9;
				border-radius: 24px;
				border: 1px solid rgba(31, 29, 26, 0.1);
				padding: 24px;
				text-align: center;
			}
			h1 { margin: 0 0 8px; font-size: 28px; }
			p { margin: 0; color: #6f675d; line-height: 1.5; }
			a {
				display: inline-block;
				margin-top: 18px;
				background: #d95f1a;
				color: #fff;
				text-decoration: none;
				padding: 12px 16px;
				border-radius: 999px;
				font-weight: 700;
			}
		</style>
	</head>
	<body>
		<div class="box">
			<h1>${safeTitle}</h1>
			<p>${safeMessage}</p>
			<a href="${safeCtaHref}" target="_blank" rel="noopener">${safeCtaLabel}</a>
		</div>
	</body>
</html>`;
}
